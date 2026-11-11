import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kolumn/data/database.dart';
import 'package:kolumn/data/lanes.dart';
import 'package:kolumn/data/repository.dart';
import 'package:kolumn/sync/hub_client.dart';
import 'package:kolumn/sync/sync_service.dart';

/// A stand-in hub with the same answers as the real one, in memory.
class FakeHub {
  final received = <Map<String, dynamic>>[];
  Map<String, dynamic> pullBody = {'cursor': 1, 'boardIds': <String>[], 'boards': [], 'columns': [], 'cards': [], 'people': [], 'me': {'id': 7, 'name': 'Clay', 'level': 'write', 'manager': true}};
  final pulls = <Uri>[];
  String rejectName = '';
  bool offline = false;
  int expireNextCall = 0;
  int refreshes = 0;
  bool refreshRefused = false;
  String password = 'right';

  late final MockClient client = MockClient((req) async {
    if (offline) throw http.ClientException('no connection');
    final path = req.url.path;
    if (path.endsWith('/auth/device/login')) {
      final b = jsonDecode(req.body) as Map;
      if (b['password'] != password) {
        return http.Response(jsonEncode({'code': 'ca_hub_invalid_credentials', 'message': 'Those sign-in details were not recognised.', 'data': {'status': 401}}), 401);
      }
      return http.Response(jsonEncode({'token': 't1', 'expires_in': 900, 'refresh': 'r1', 'user': {'id': 7, 'display_name': 'Clay'}}), 200);
    }
    if (path.endsWith('/auth/device/refresh')) {
      refreshes++;
      if (refreshRefused) return http.Response(jsonEncode({'code': 'ca_hub_refresh_failed', 'message': 'Session is not valid.', 'data': {'status': 401}}), 401);
      return http.Response(jsonEncode({'token': 't2', 'expires_in': 900, 'refresh': 'r2', 'user': {'id': 7, 'display_name': 'Clay'}}), 200);
    }
    if (path.endsWith('/kolumn/sync')) {
      if (expireNextCall > 0) {
        expireNextCall--;
        return http.Response(jsonEncode({'code': 'rest_forbidden', 'message': 'expired', 'data': {'status': 401}}), 401);
      }
      if (req.method == 'POST') {
        final muts = ((jsonDecode(req.body) as Map)['mutations'] as List).cast<Map<String, dynamic>>();
        received.addAll(muts);
        return http.Response(
          jsonEncode({
            'results': [for (final m in muts) {'mutation_id': m['mutation_id'], 'outcome': m['name'] == rejectName ? 'rejected' : 'applied'}],
          }),
          200,
        );
      }
      pulls.add(req.url);
      return http.Response(jsonEncode(pullBody), 200);
    }
    return http.Response('{}', 404);
  });
}

void main() {
  late KolumnDb db;
  late KolumnRepository repo;
  late FakeHub hub;
  late MemoryCredentialStore creds;
  late SyncService sync;

  setUp(() {
    db = KolumnDb.forTesting(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    repo = KolumnRepository(db);
    hub = FakeHub();
    creds = MemoryCredentialStore();
    sync = SyncService(repo: repo, hub: HubClient(credentials: creds, httpClient: hub.client, server: 'https://hub.test'));
  });

  tearDown(() => db.close());

  Map<String, dynamic> board(String id, {bool all = true, List<int> members = const []}) =>
      {'id': id, 'name': 'Tour', 'tidyDays': null, 'allAccess': all, 'creatorId': 7, 'members': members, 'canManage': true, 'createdAt': 1, 'updatedAt': 1, 'deletedAt': null};
  Map<String, dynamic> card(String id, String boardId, {String title = 'A', int number = 5, int rev = 1}) => {
    'id': id, 'boardId': boardId, 'number': number, 'title': title, 'description': '', 'columnId': null, 'closedAt': null, 'laterAt': null,
    'laterReason': null, 'priorityAt': null, 'dueAt': null, 'dueHasTime': false, 'lastActiveAt': 10, 'creatorId': 7, 'rev': rev,
    'createdAt': 1, 'updatedAt': 1, 'deletedAt': null,
  };

  test('wrong details are refused with the hub\'s own message', () async {
    final err = await sync.signIn('clay', 'wrong');
    expect(err, 'Those sign-in details were not recognised.');
    expect(await creds.read(), isNull);
  });

  test('signing in keeps the session in safe storage and fetches everything', () async {
    hub.pullBody = {...hub.pullBody, 'boardIds': ['b1'], 'boards': [board('b1')], 'cards': [card('c1', 'b1')]};
    expect(await sync.signIn('clay', 'right'), isNull);
    expect(await creds.read(), 'r1');
    expect(hub.pulls.single.queryParameters['cursor'], '0', reason: 'the first fetch is a full one');
    final c = await repo.card('c1');
    expect(c!.synced, isTrue);
    expect(c.number, 5, reason: 'the hub gives out card numbers');
    expect(sync.current.state, SyncState.upToDate);
  });

  test('a first sign-in to an empty hub sends up the practice board', () async {
    expect(await sync.signIn('clay', 'right'), isNull);
    final names = hub.received.map((m) => m['name']).toList();
    expect(names.first, 'board.create');
    expect(names.where((n) => n == 'card.create'), hasLength(7));
  });

  test('changes made on the phone go out in order, each once, then leave the queue', () async {
    await creds.write('r1');
    final b = await repo.createBoard('Tour');
    final c = await repo.addCard(b, 'Book the van');
    await repo.moveCard(c, const Lane.done());
    hub.pullBody = {...hub.pullBody, 'boardIds': [b], 'boards': [board(b)], 'cards': [card(c, b)]};
    await sync.syncNow();
    expect(hub.received.map((m) => m['name']), ['board.create', 'card.create', 'card.move']);
    expect(hub.received.map((m) => m['mutation_id']).toSet(), hasLength(3));
    expect(await repo.pendingCount(), 0);
  });

  test('offline: nothing is lost, the changes wait, and the board says so', () async {
    await creds.write('r1');
    final b = await repo.createBoard('Tour');
    await repo.addCard(b, 'Merch count');
    hub.offline = true;
    await sync.syncNow();
    expect(sync.current.state, SyncState.offline);
    expect(await repo.pendingCount(), 2);
    expect(await creds.read(), 'r1', reason: 'no connection never signs anyone out');
    hub.offline = false;
    hub.pullBody = {...hub.pullBody, 'boardIds': [b], 'boards': [board(b)]};
    await sync.syncNow();
    expect(await repo.pendingCount(), 0);
    expect(hub.received, hasLength(2));
  });

  test('an expired pass is renewed quietly and the request tried again', () async {
    await creds.write('r1');
    hub.expireNextCall = 1;
    await sync.syncNow();
    expect(hub.refreshes, greaterThanOrEqualTo(1));
    expect(sync.current.state, SyncState.upToDate);
    expect(await creds.read(), 'r2', reason: 'the renewed credential replaces the old one');
  });

  test('only the hub saying no ends the session', () async {
    await creds.write('r1');
    hub.refreshRefused = true;
    await sync.syncNow();
    expect(sync.current.state, SyncState.signedOut);
    expect(await creds.read(), isNull);
  });

  test('a turned-down change makes the next fetch a full one that puts the phone right', () async {
    await creds.write('r1');
    await repo.setSetting('sync.cursor', '40');
    final b = await repo.createBoard('Tour');
    final stray = await repo.addCard(b, 'Not allowed');
    hub.rejectName = 'card.create';
    hub.pullBody = {...hub.pullBody, 'boardIds': [b], 'boards': [board(b)], 'cards': []};
    await sync.syncNow();
    expect(hub.pulls.last.queryParameters['cursor'], '0');
    expect(await repo.card(stray), isNull, reason: 'the card the hub refused is taken back off the phone');
  });

  test('a board taken away disappears from the phone with its cards', () async {
    await creds.write('r1');
    hub.pullBody = {...hub.pullBody, 'boardIds': ['b1', 'b2'], 'boards': [board('b1'), board('b2')], 'cards': [card('c1', 'b1'), card('c2', 'b2')]};
    await sync.syncNow(full: true);
    expect(await repo.card('c2'), isNotNull);
    hub.pullBody = {...hub.pullBody, 'cursor': 2, 'boardIds': ['b1'], 'boards': [], 'cards': []};
    await sync.syncNow();
    expect(await repo.card('c2'), isNull);
    expect(await repo.card('c1'), isNotNull);
    expect(hub.pulls.last.queryParameters['known'], anyOf('b1,b2', 'b2,b1'), reason: 'the phone says which boards it already holds');
  });

  test('what the phone changed but has not sent is not overwritten by an older copy', () async {
    await creds.write('r1');
    hub.pullBody = {...hub.pullBody, 'boardIds': ['b1'], 'boards': [board('b1')], 'cards': [card('c1', 'b1', title: 'Old title')]};
    await sync.syncNow(full: true);
    await repo.editCard('c1', title: 'New title');
    hub.offline = true;
    await sync.syncNow();
    hub.offline = false;
    // The hub has not seen the edit yet when this pull is answered.
    final got = await repo.card('c1');
    expect(got!.title, 'New title');
    final edit = (await repo.pendingOutbox()).single;
    expect(jsonDecode(edit.args)['baseRev'], 1, reason: 'the edit says which copy it was made on, so a clash keeps both texts');
  });

  test('signing out takes the shared boards off the phone', () async {
    await creds.write('r1');
    hub.pullBody = {...hub.pullBody, 'boardIds': ['b1'], 'boards': [board('b1')], 'cards': [card('c1', 'b1')]};
    await sync.syncNow(full: true);
    await sync.signOut();
    expect(await repo.card('c1'), isNull);
    expect(await creds.read(), isNull);
    expect(sync.current.state, SyncState.signedOut);
  });

  test('board sharing goes to the hub as one change', () async {
    final b = await repo.createBoard('Private');
    await repo.setBoardAccess(b, allAccess: false, members: [7, 9]);
    final last = (await repo.pendingOutbox()).last;
    expect(last.name, 'board.access');
    expect(jsonDecode(last.args), {'id': b, 'allAccess': false, 'members': [7, 9]});
  });
}
