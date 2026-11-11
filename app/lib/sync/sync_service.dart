import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';

import '../data/database.dart';
import '../data/repository.dart';
import '../planner/days.dart';
import 'hub_client.dart';

enum SyncState { signedOut, checking, upToDate, offline, noAccess }

class SyncStatus {
  const SyncStatus(this.state, {this.lastSynced, this.message});
  final SyncState state;
  final DateTime? lastSynced;
  final String? message;
}

/// Keeps this phone and the hub in step: sends what changed here, then takes
/// in what changed for everyone else. Runs once a minute while Kolumn is on
/// screen, the moment it comes back on screen, a couple of seconds after any
/// change here, and whenever the refresh button is tapped.
class SyncService with WidgetsBindingObserver {
  SyncService({required this.repo, required this.hub});

  final KolumnRepository repo;
  final HubClient hub;

  static const interval = Duration(seconds: 60);
  static const afterChange = Duration(seconds: 2);

  final _status = StreamController<SyncStatus>.broadcast();
  SyncStatus _current = const SyncStatus(SyncState.signedOut);
  SyncStatus get current => _current;
  Stream<SyncStatus> get status async* {
    yield _current;
    yield* _status.stream;
  }

  Timer? _timer;
  Timer? _nudge;
  StreamSubscription<int>? _pendingSub;
  bool _running = false;
  bool _again = false;
  bool _started = false;

  void _set(SyncStatus s) {
    _current = s;
    if (!_status.isClosed) _status.add(s);
  }

  /// Call once at launch.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    if (!await hub.hasSession) {
      _set(const SyncStatus(SyncState.signedOut));
    } else {
      _set(SyncStatus(SyncState.checking, lastSynced: _current.lastSynced));
      unawaited(syncNow());
    }
    _timer = Timer.periodic(interval, (_) => syncNow());
    var last = -1;
    _pendingSub = repo.watchPendingCount().listen((n) {
      if (n > last && last >= 0) {
        _nudge?.cancel();
        _nudge = Timer(afterChange, syncNow);
      }
      last = n;
    });
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _nudge?.cancel();
    _pendingSub?.cancel();
    _status.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timer?.cancel();
      _timer = Timer.periodic(interval, (_) => syncNow());
      syncNow();
    } else if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    }
  }

  Future<String?> signIn(String username, String password) async {
    try {
      await hub.signIn(username.trim(), password);
    } on HubRefusal catch (e) {
      if (e.status == 429 || e.code.contains('rate')) {
        return 'Too many tries. Wait a few minutes, then try again.';
      }
      return e.message;
    } on HubUnreachable {
      return 'Can\'t reach the hub. Check your connection and try again.';
    }
    await syncNow(full: true);
    return null;
  }

  Future<void> signOut() async {
    await hub.signOut();
    await repo.forgetSharedData();
    _set(const SyncStatus(SyncState.signedOut));
  }

  /// One round: send, then fetch. Safe to call any time; overlapping calls
  /// fold into one more round.
  Future<void> syncNow({bool full = false}) async {
    if (_running) {
      _again = true;
      return;
    }
    if (!await hub.hasSession) {
      _set(const SyncStatus(SyncState.signedOut));
      return;
    }
    _running = true;
    _set(SyncStatus(SyncState.checking, lastSynced: _current.lastSynced));
    try {
      // Tweek's "move unfinished to the next day", done on this phone so it
      // works offline too; the moves go out with everything else.
      if ((await repo.setting('me.level')) != 'read') await repo.rollOver(todayKey());
      var needFull = full || (await repo.setting('sync.cursor')) == null;
      needFull = await _pushAll() || needFull;
      await _pull(full: needFull);
      // A first sign-in to an empty hub gets the practice board, then sends it.
      if ((await repo.setting('me.level')) != 'read' && (await repo.watchBoards().first).isEmpty) {
        await repo.ensureStarterBoard();
        await _pushAll();
        await _pull(full: false);
      }
      // Everyone gets a planner of their own to start with, once the hub has
      // said it keeps planners (an older hub does not).
      if ((await repo.setting('me.level')) != 'read' && (await repo.setting('sync.plannerIds')) != null && (await repo.watchPlanners().first).isEmpty) {
        await repo.ensureStarterPlanner();
        await _pushAll();
        await _pull(full: false);
      }
      await repo.setSetting('sync.last', '${DateTime.now().millisecondsSinceEpoch}');
      _set(SyncStatus(SyncState.upToDate, lastSynced: DateTime.now()));
    } on HubRefusal catch (e) {
      if (e.signedOut) {
        _set(SyncStatus(SyncState.signedOut, message: e.message));
      } else if (e.noAccess) {
        _set(SyncStatus(SyncState.noAccess, message: e.message));
      } else {
        _set(SyncStatus(SyncState.offline, lastSynced: _current.lastSynced, message: e.message));
      }
    } on HubUnreachable {
      _set(SyncStatus(SyncState.offline, lastSynced: _current.lastSynced));
    } finally {
      _running = false;
      if (_again) {
        _again = false;
        unawaited(syncNow());
      }
    }
  }

  /// Sends everything waiting, in order. Files go one at a time between the
  /// other changes, so a card always reaches the hub before its photo. True
  /// when the hub turned something down, so the next fetch should be a full
  /// one to put this phone right.
  Future<bool> _pushAll() async {
    var refused = false;
    for (var round = 0; round < 100; round++) {
      final waiting = await repo.pendingOutbox(limit: 200);
      if (waiting.isEmpty) break;
      if (_isUpload(waiting.first.name)) {
        refused = await _uploadOne(waiting.first) || refused;
        continue;
      }
      final batch = waiting.takeWhile((e) => !_isUpload(e.name)).toList();
      Map<String, dynamic> reply;
      try {
        reply = await hub.push([
          for (final e in batch) {'mutation_id': e.mutationId, 'name': e.name, 'args': jsonDecode(e.args), 'client_ts': e.clientTs},
        ]);
      } on HubRefusal catch (e) {
        if (e.readOnly) {
          // This person may look but not change: what is waiting can never go.
          await repo.removeOutbox(waiting.map((b) => b.mutationId));
          return true;
        }
        rethrow;
      }
      final results = (reply['results'] as List?) ?? const [];
      final done = <String>[];
      for (final r in results) {
        final m = r as Map<String, dynamic>;
        done.add(m['mutation_id'] as String);
        if (m['outcome'] == 'rejected') refused = true;
      }
      if (done.isEmpty) break;
      await repo.removeOutbox(done);
    }
    return refused;
  }

  static bool _isUpload(String name) => name == 'file.upload' || name == 'todofile.upload';

  /// One waiting file. A file that has gone from the phone, or a card the
  /// hub no longer lets this person reach, is dropped rather than retried.
  Future<bool> _uploadOne(KOutboxEntry e) async {
    final a = jsonDecode(e.args) as Map<String, dynamic>;
    final id = a['id'] as String;
    final f = File(a['path'] as String? ?? '');
    if (!f.existsSync()) {
      await repo.removeOutbox([e.mutationId]);
      return true;
    }
    try {
      await hub.uploadFile(
        id: id,
        cardId: a['cardId'] as String?,
        todoId: a['todoId'] as String?,
        filename: a['filename'] as String? ?? 'file',
        cover: a['cover'] == true,
        bytes: await f.readAsBytes(),
      );
    } on HubRefusal catch (r) {
      if (r.signedOut) rethrow;
      await repo.removeOutbox([e.mutationId]);
      return true;
    }
    if (e.name == 'todofile.upload') {
      await repo.markTodoFileUploaded(id);
    } else {
      await repo.markFileUploaded(id);
    }
    await repo.removeOutbox([e.mutationId]);
    return false;
  }

  Future<void> _pull({required bool full}) async {
    final cursor = full ? 0 : int.tryParse(await repo.setting('sync.cursor') ?? '') ?? 0;
    final known = full ? <String>[] : await repo.knownBoardIds();
    final knownPlanners = full ? <String>[] : await repo.knownPlannerIds();
    final body = await hub.pull(cursor: cursor, known: known, knownPlanners: knownPlanners);
    await repo.applyPull(body, replaceAll: full);
  }
}
