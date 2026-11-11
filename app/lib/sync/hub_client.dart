import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Where the hub lives. The live site unless the app is built for the
/// practice site with `--dart-define=KOLUMN_SERVER=https://stage5230ca.clayaiken.com`.
const String kolumnServer = String.fromEnvironment('KOLUMN_SERVER', defaultValue: 'https://clayaiken.com');

const String _ua = 'Kolumn/0.4 (Android)';

/// Something the hub refused, with the hub's own plain message.
class HubRefusal implements Exception {
  HubRefusal(this.status, this.code, this.message);
  final int status;
  final String code;
  final String message;

  bool get signedOut => status == 401 || code == 'ca_hub_not_approved';
  bool get noAccess => code == 'ca_hub_no_access' || code == 'ca_kolumn_no_access';
  bool get readOnly => code == 'ca_hub_read_only';

  @override
  String toString() => 'HubRefusal($status, $code, $message)';
}

/// No connection, a timeout, or a reply that was not the hub's.
class HubUnreachable implements Exception {
  HubUnreachable(this.reason);
  final String reason;
  @override
  String toString() => 'HubUnreachable($reason)';
}

/// Where the refresh credential is kept. On the phone that is Android's
/// encrypted storage; tests use a plain map.
abstract class CredentialStore {
  Future<String?> read();
  Future<void> write(String? value);
}

class SecureCredentialStore implements CredentialStore {
  static const _key = 'kolumn.refresh';
  final _storage = const FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String? value) => value == null ? _storage.delete(key: _key) : _storage.write(key: _key, value: value);
}

class MemoryCredentialStore implements CredentialStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String? v) async => value = v;
}

class HubUser {
  HubUser(this.id, this.name);
  final int id;
  final String name;
}

/// Talks to the hub: signing in with a hub login, keeping the session fresh
/// under the hub's own rules (only a refusal signs anyone out; a dropped
/// reply never does), and the two Kolumn sync calls.
class HubClient {
  HubClient({required this.credentials, http.Client? httpClient, String? server})
    : _http = httpClient ?? http.Client(),
      _base = '${server ?? kolumnServer}/wp-json/hub/v1';

  final CredentialStore credentials;
  final http.Client _http;
  final String _base;

  String? _token;
  DateTime _tokenExpires = DateTime.fromMillisecondsSinceEpoch(0);
  Future<void>? _refreshing;

  Future<bool> get hasSession async => (await credentials.read()) != null;

  Map<String, String> get _jsonHeaders => {'Content-Type': 'application/json', 'Accept': 'application/json', 'User-Agent': _ua};

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw HubUnreachable('timeout');
    } on http.ClientException catch (e) {
      throw HubUnreachable(e.message);
    } catch (e) {
      if (e is HubRefusal) rethrow;
      throw HubUnreachable('$e');
    }
  }

  Map<String, dynamic> _decode(http.Response r) {
    Object? body;
    try {
      body = jsonDecode(r.body);
    } catch (_) {
      throw HubUnreachable('not the hub (${r.statusCode})');
    }
    if (r.statusCode >= 200 && r.statusCode < 300 && body is Map<String, dynamic>) return body;
    if (body is Map<String, dynamic> && body['code'] is String) {
      throw HubRefusal(r.statusCode, body['code'] as String, (body['message'] as String?) ?? 'The hub said no.');
    }
    throw HubUnreachable('unexpected reply (${r.statusCode})');
  }

  void _takeToken(Map<String, dynamic> body) {
    _token = body['token'] as String?;
    final ttl = (body['expires_in'] as num?)?.toInt() ?? 900;
    _tokenExpires = DateTime.now().add(Duration(seconds: ttl - 60));
  }

  Future<HubUser> signIn(String username, String password) async {
    final r = await _send(
      () => _http.post(Uri.parse('$_base/auth/device/login'), headers: _jsonHeaders, body: jsonEncode({'username': username, 'password': password})),
    );
    final body = _decode(r);
    await credentials.write(body['refresh'] as String?);
    _takeToken(body);
    final u = body['user'] as Map<String, dynamic>? ?? const {};
    return HubUser((u['id'] as num?)?.toInt() ?? 0, (u['display_name'] as String?) ?? '');
  }

  Future<void> signOut() async {
    final refresh = await credentials.read();
    await credentials.write(null);
    _token = null;
    if (refresh == null) return;
    try {
      await _send(() => _http.post(Uri.parse('$_base/auth/device/logout'), headers: _jsonHeaders, body: jsonEncode({'refresh': refresh})));
    } catch (_) {
      // Signing out on the phone works offline; the hub session lapses on its own.
    }
  }

  /// Renews the session. Only the hub saying "no" (401/403) ends it; no
  /// connection leaves everything as it was.
  Future<void> _refresh() {
    return _refreshing ??= () async {
      try {
        final refresh = await credentials.read();
        if (refresh == null) throw HubRefusal(401, 'kolumn_signed_out', 'Not signed in.');
        final r = await _send(() => _http.post(Uri.parse('$_base/auth/device/refresh'), headers: _jsonHeaders, body: jsonEncode({'refresh': refresh})));
        try {
          final body = _decode(r);
          await credentials.write(body['refresh'] as String?);
          _takeToken(body);
        } on HubRefusal catch (e) {
          if (e.status == 401 || e.status == 403) await credentials.write(null);
          rethrow;
        }
      } finally {
        _refreshing = null;
      }
    }();
  }

  Future<Map<String, dynamic>> _authed(Future<http.Response> Function(Map<String, String> headers) call) async {
    if (_token == null || DateTime.now().isAfter(_tokenExpires)) await _refresh();
    Map<String, String> h() => {..._jsonHeaders, 'Authorization': 'Bearer $_token'};
    var r = await _send(() => call(h()));
    if (r.statusCode == 401) {
      await _refresh();
      r = await _send(() => call(h()));
    }
    return _decode(r);
  }

  Future<Map<String, dynamic>> pull({required int cursor, required List<String> known}) =>
      _authed((h) => _http.get(Uri.parse('$_base/kolumn/sync').replace(queryParameters: {'cursor': '$cursor', 'known': known.join(',')}), headers: h));

  /// Sends one file as the request body. Safe to repeat: the hub keeps one copy per id.
  Future<Map<String, dynamic>> uploadFile({
    required String id,
    required String cardId,
    required String filename,
    required bool cover,
    required List<int> bytes,
  }) => _authed(
    (h) => _http.post(
      Uri.parse('$_base/kolumn/files').replace(queryParameters: {'id': id, 'cardId': cardId, 'filename': filename, 'cover': cover ? '1' : '0'}),
      headers: {...h, 'Content-Type': 'application/octet-stream'},
      body: bytes,
    ),
  );

  /// A file's bytes (or its small preview), after the hub's board check.
  Future<List<int>> downloadFile(String id, {bool thumb = false}) async {
    if (_token == null || DateTime.now().isAfter(_tokenExpires)) await _refresh();
    final uri = Uri.parse('$_base/kolumn/files/$id').replace(queryParameters: thumb ? {'size': 'thumb'} : null);
    var r = await _send(() => _http.get(uri, headers: {'Authorization': 'Bearer $_token', 'User-Agent': _ua}));
    if (r.statusCode == 401) {
      await _refresh();
      r = await _send(() => _http.get(uri, headers: {'Authorization': 'Bearer $_token', 'User-Agent': _ua}));
    }
    if (r.statusCode != 200) _decode(r);
    return r.bodyBytes;
  }

  Future<Map<String, dynamic>> push(List<Map<String, dynamic>> mutations) =>
      _authed((h) => _http.post(Uri.parse('$_base/kolumn/sync'), headers: h, body: jsonEncode({'mutations': mutations})));
}
