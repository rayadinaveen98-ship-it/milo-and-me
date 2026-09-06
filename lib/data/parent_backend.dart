import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/models.dart';

class Entitlement {
  final String status, productId;
  final DateTime expiresAt;
  const Entitlement({
    required this.status,
    required this.productId,
    required this.expiresAt,
  });
  bool validAt(DateTime now) =>
      status == 'active' && now.toUtc().isBefore(expiresAt.toUtc());
}

abstract interface class ParentBackend {
  Future<List<Json>> catalogue();
  Future<Entitlement?> entitlement();
}

// Optional adapter, deliberately not created in offline bootstrap. Parent auth
// must inject a refreshed access token from platform secure storage. This
// adapter never receives child nicknames, drawings or interaction histories.
class SupabaseParentBackend implements ParentBackend {
  final Uri base;
  final String publishableKey;
  final Future<String> Function() accessToken;
  final http.Client client;
  SupabaseParentBackend({
    required this.base,
    required this.publishableKey,
    required this.accessToken,
    required this.client,
  }) {
    if (base.scheme != 'https') throw ArgumentError('HTTPS is required');
  }
  Future<List<Json>> _select(String path) async {
    final token = await accessToken();
    if (token.isEmpty) throw StateError('Parent sign-in required');
    final response = await client
        .get(
          base.resolve(path),
          headers: {
            'apikey': publishableKey,
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 401) throw StateError('Parent session expired');
    if (response.statusCode != 200) {
      throw StateError('Parent service unavailable');
    }
    if (response.bodyBytes.length > 1024 * 1024) {
      throw const FormatException('Catalogue response too large');
    }
    final body = jsonDecode(response.body);
    if (body is! List) throw const FormatException('Invalid response');
    return body.map((r) => Map<String, dynamic>.from(r)).toList();
  }

  @override
  Future<List<Json>> catalogue() => _select(
    '/rest/v1/content_packs?select=id,title,version,download_url,sha256,price_tier&published=eq.true&limit=100',
  );
  @override
  Future<Entitlement?> entitlement() async {
    // RLS limits this to the current parent; sensitive writes are server-only.
    final rows = await _select(
      '/rest/v1/entitlements?select=status,product_id,expires_at&order=expires_at.desc&limit=1',
    );
    if (rows.isEmpty) return null;
    final r = rows.single;
    return Entitlement(
      status: r['status'],
      productId: r['product_id'],
      expiresAt: DateTime.parse(r['expires_at']),
    );
  }
}
