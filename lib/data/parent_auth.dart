import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../domain/models.dart';

abstract interface class TokenVault {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> clear();
}

class SecureTokenVault implements TokenVault {
  final FlutterSecureStorage storage;
  SecureTokenVault({this.storage = const FlutterSecureStorage()});
  @override
  Future<String?> read() => storage.read(key: 'parent.session');
  @override
  Future<void> write(String value) =>
      storage.write(key: 'parent.session', value: value);
  @override
  Future<void> clear() => storage.delete(key: 'parent.session');
}

class MemoryTokenVault implements TokenVault {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async {
    this.value = value;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

abstract interface class ParentAuth {
  String? get parentId;
  Future<void> requestCode(String email);
  Future<void> verifyCode(String email, String code);
  Future<String> accessToken();
  Future<void> signOut();
}

class SupabaseParentAuth implements ParentAuth {
  final Uri base;
  final String publishableKey;
  final http.Client client;
  final TokenVault vault;
  Json? _session;
  Future<String>? _refreshing;
  SupabaseParentAuth({
    required this.base,
    required this.publishableKey,
    required this.client,
    required this.vault,
  }) {
    if (base.scheme != 'https') throw ArgumentError('HTTPS required');
  }
  @override
  String? get parentId => _session?['user']?['id'];
  Future<Json> _post(String path, Json data, {String? token}) async {
    final r = await client
        .post(
          base.resolve(path),
          headers: {
            'apikey': publishableKey,
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 20));
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw StateError(
        'Parent sign-in unavailable. Check the code or try again later.',
      );
    }
    if (r.bodyBytes.length > 128 * 1024) {
      throw const FormatException('Invalid auth response');
    }
    return r.body.isEmpty ? {} : Map<String, dynamic>.from(jsonDecode(r.body));
  }

  @override
  Future<void> requestCode(String email) async {
    if (email.length > 254 ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      throw const FormatException('Enter your adult email address.');
    }
    await _post('/auth/v1/otp', {'email': email, 'create_user': true});
  }

  Future<void> _save(Json session) async {
    if (session['access_token'] is! String ||
        session['refresh_token'] is! String ||
        session['user']?['id'] is! String ||
        session['expires_in'] is! num) {
      throw const FormatException('Invalid parent session');
    }
    session['local_expiry'] = DateTime.now()
        .add(Duration(seconds: (session['expires_in'] as num).toInt()))
        .toIso8601String();
    await vault.write(jsonEncode(session));
    _session = session;
  }

  @override
  Future<void> verifyCode(String email, String code) async {
    if (!RegExp(r'^\d{6,8}$').hasMatch(code)) {
      throw const FormatException('Enter the code from your email.');
    }
    await _save(
      await _post('/auth/v1/verify', {
        'email': email,
        'token': code,
        'type': 'email',
      }),
    );
  }

  @override
  Future<String> accessToken() async {
    _session ??= await _stored();
    if (_session == null) throw StateError('Parent sign-in required');
    if (DateTime.parse(
      _session!['local_expiry'],
    ).isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      return _session!['access_token'];
    }
    return _refreshing ??= _refresh().whenComplete(() => _refreshing = null);
  }

  Future<Json?> _stored() async {
    final raw = await vault.read();
    return raw == null ? null : Map<String, dynamic>.from(jsonDecode(raw));
  }

  Future<String> _refresh() async {
    await _save(
      await _post('/auth/v1/token?grant_type=refresh_token', {
        'refresh_token': _session!['refresh_token'],
      }),
    );
    return _session!['access_token'];
  }

  @override
  Future<void> signOut() async {
    try {
      final token = await accessToken();
      await _post('/auth/v1/logout?scope=global', {}, token: token);
    } finally {
      _session = null;
      await vault.clear();
    }
  }
}
