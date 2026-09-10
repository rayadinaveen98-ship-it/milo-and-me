import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../core/service_config.dart';
import '../domain/models.dart';
import '../domain/access_policy.dart';
import 'parent_auth.dart';
import 'parent_backend.dart';
import 'purchase_store.dart';

class ParentServices extends ChangeNotifier {
  final bool Function() authorized;
  final AccessPolicy access;
  final http.Client client;
  final FlutterSecureStorage secure;
  ParentAuth? auth;
  PurchaseStore? store;
  PurchaseCoordinator? _purchases;
  List<Json> catalogue = [];
  List<StoreProduct> products = [];
  String status = '';
  bool disposed = false;
  bool get live => ServiceConfig.live;
  ParentServices({
    required this.authorized,
    required this.access,
    http.Client? client,
    this.secure = const FlutterSecureStorage(),
  }) : client = client ?? http.Client();
  void guard() {
    if (!authorized()) throw StateError('Open the parent gate first.');
  }

  void report(String message) {
    status = message;
    if (!disposed) notifyListeners();
  }

  Future<void> cachedAccess() async {
    if (!live) return;
    try {
      final raw = await secure.read(key: 'parent.entitlement');
      if (raw != null) {
        final d = jsonDecode(raw);
        access.entitlement = Entitlement(
          status: d['status'],
          productId: d['product_id'],
          expiresAt: DateTime.parse(d['expires_at']),
        );
      }
    } catch (_) {
      /* Missing cache never blocks bundled free play. */
    }
  }

  ParentAuth _auth() {
    if (!ServiceConfig.configured) {
      throw StateError(
        'Live parent services need configuration. Offline play remains available.',
      );
    }
    return auth ??= SupabaseParentAuth(
      base: Uri.parse(ServiceConfig.url),
      publishableKey: ServiceConfig.key,
      client: client,
      vault: SecureTokenVault(storage: secure),
    );
  }

  Future<void> requestCode(String email) async {
    guard();
    if (!live) throw StateError('No email is sent in the offline playtest.');
    await _auth().requestCode(email);
    report('Check your email for a sign-in code.');
  }

  Future<void> verifyCode(String email, String code, bool consent) async {
    guard();
    if (!consent) {
      throw StateError('Please review and accept the parent account notice.');
    }
    await _auth().verifyCode(email, code);
    guard();
    await _call('consent', {'policy_version': '2026-09-v1', 'accepted': true});
    await refresh();
  }

  Future<Json> _call(String action, Json data) async {
    final token = await _auth().accessToken();
    final r = await client
        .post(
          Uri.parse(ServiceConfig.url).resolve('/functions/v1/parent-api'),
          headers: {
            'apikey': ServiceConfig.key,
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'action': action, ...data}),
        )
        .timeout(const Duration(seconds: 30));
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw StateError(
        'Parent service could not complete the request. Please try again.',
      );
    }
    if (r.bodyBytes.length > 1024 * 1024) {
      throw const FormatException('Response too large');
    }
    return Map<String, dynamic>.from(jsonDecode(r.body));
  }

  Future<void> _deliver(Entitlement? e) async {
    if (e == null) {
      await secure.delete(key: 'parent.entitlement');
    } else {
      await secure.write(
        key: 'parent.entitlement',
        value: jsonEncode({
          'status': e.status,
          'product_id': e.productId,
          'expires_at': e.expiresAt.toIso8601String(),
        }),
      );
    }
    access.entitlement = e;
    report('Parent access updated.');
  }

  Future<void> refresh() async {
    guard();
    if (!live) {
      report(
        'Offline playtest: the included library is open. No subscription is active.',
      );
      return;
    }
    final a = _auth();
    await a.accessToken();
    final backend = SupabaseParentBackend(
      base: Uri.parse(ServiceConfig.url),
      publishableKey: ServiceConfig.key,
      accessToken: a.accessToken,
      client: client,
    );
    final rows = await backend.catalogue();
    final result = await _call('entitlement', {});
    guard();
    catalogue = rows;
    final e = result['entitlement'];
    await _deliver(
      e == null
          ? null
          : Entitlement(
              status: e['status'],
              productId: e['product_id'],
              expiresAt: DateTime.parse(e['expires_at']),
            ),
    );
  }

  Future<void> loadStore() async {
    guard();
    if (live) {
      await _auth().accessToken();
      if (ServiceConfig.products.length != 2) {
        throw StateError('Monthly and annual products need configuration.');
      }
    }
    store ??= live ? GooglePurchaseStore() : SandboxPurchaseStore();
    _purchases ??= PurchaseCoordinator(
      store: store!,
      verify: (r) async {
        if (!live) {
          if (r.source != 'sandbox' || !r.token.startsWith('sandbox:')) {
            throw StateError('Invalid simulation');
          }
          return Entitlement(
            status: 'active',
            productId: r.productId,
            expiresAt: DateTime.now().add(const Duration(days: 1)),
          );
        }
        if (r.source != 'google_play') {
          throw StateError(
            'Only Google Play receipts are enabled for this Android release.',
          );
        }
        final d = await _call('verify_purchase', {
          'product_id': r.productId,
          'purchase_token': r.token,
        });
        return Entitlement(
          status: d['status'],
          productId: d['product_id'],
          expiresAt: DateTime.parse(d['expires_at']),
        );
      },
      deliver: (e) async {
        if (live) await _deliver(e);
      },
      report: (s) => report(live ? s : 'Simulation only · $s'),
    );
    products = await store!.products(
      live ? ServiceConfig.products : {'test-monthly', 'test-annual'},
    );
    report(
      live
          ? 'Prices come from Google Play. Subscriptions renew until cancelled in Google Play.'
          : 'Test store only. These buttons never charge money.',
    );
  }

  Future<void> buy(String id) async {
    guard();
    if (store == null) throw StateError('Load the store first.');
    if (live && access.premium) {
      throw StateError(
        'An active plan already covers this account. Manage it in Google Play.',
      );
    }
    await store!.buy(id, live ? _auth().parentId! : 'local-test-parent');
    report(
      live
          ? 'Waiting for the store and verification.'
          : 'Running a no-charge simulation.',
    );
  }

  Future<void> restore() async {
    guard();
    if (store == null) await loadStore();
    await store!.restore();
    report(
      live
          ? 'Restore requested. Only verified purchases unlock access.'
          : 'Simulated restore requested.',
    );
  }

  Future<void> signOut() async {
    guard();
    try {
      if (auth != null) await auth!.signOut();
    } finally {
      await _deliver(null);
      catalogue = [];
      report('Signed out on this device.');
    }
  }

  Future<void> deleteAccount() async {
    guard();
    if (!live) {
      report('This playtest has no cloud account to delete.');
      return;
    }
    await _call('delete_account', {'confirm': true});
    await secure.delete(key: 'parent.session');
    auth = null;
    await _deliver(null);
    catalogue = [];
    report(
      'Parent cloud account deleted. Local creations remain. Store subscriptions must be cancelled separately in Google Play.',
    );
  }

  @override
  void dispose() {
    disposed = true;
    unawaited(_purchases?.dispose() ?? Future.value());
    client.close();
    super.dispose();
  }
}
