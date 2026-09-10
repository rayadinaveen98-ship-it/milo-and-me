import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:milo_and_me/data/parent_auth.dart';
import 'package:milo_and_me/data/parent_backend.dart';
import 'package:milo_and_me/data/purchase_store.dart';
import 'package:milo_and_me/domain/access_policy.dart';

void main() {
  test(
    'Adult OTP saves tokens only in vault and refreshes an expired session',
    () async {
      final vault = MemoryTokenVault();
      var refreshes = 0;
      final client = MockClient((r) async {
        final data = jsonDecode(r.body);
        expect(data.containsKey('nickname'), isFalse);
        if (r.url.path.endsWith('/otp')) {
          expect(data['email'], 'adult@example.com');
          return http.Response('{}', 200);
        }
        if (r.url.path.endsWith('/token')) refreshes++;
        return http.Response(
          jsonEncode({
            'access_token': 'verified-parent',
            'refresh_token': 'refresh-test',
            'expires_in': r.url.path.endsWith('/verify') ? -1 : 3600,
            'user': {'id': 'parent-id'},
          }),
          200,
        );
      });
      final auth = SupabaseParentAuth(
        base: Uri.parse('https://fixture.test'),
        publishableKey: 'public-test',
        client: client,
        vault: vault,
      );
      await auth.requestCode('adult@example.com');
      await auth.verifyCode('adult@example.com', '123456');
      expect(auth.parentId, 'parent-id');
      final tokens = await Future.wait([
        auth.accessToken(),
        auth.accessToken(),
      ]);
      expect(tokens, ['verified-parent', 'verified-parent']);
      expect(refreshes, 1);
      expect(vault.value, isNotNull);
      await auth.signOut();
      expect(vault.value, isNull);
      client.close();
    },
  );
  test(
    'Invalid email code cannot create a cached authenticated session',
    () async {
      final vault = MemoryTokenVault();
      final client = MockClient((_) async => http.Response('{}', 401));
      final auth = SupabaseParentAuth(
        base: Uri.parse('https://fixture.test'),
        publishableKey: 'public-test',
        client: client,
        vault: vault,
      );
      await expectLater(
        auth.verifyCode('adult@example.com', '123456'),
        throwsStateError,
      );
      expect(vault.value, isNull);
      expect(auth.parentId, isNull);
      client.close();
    },
  );
  test(
    'Restore repeats server verification before delivery and completion',
    () async {
      final store = SandboxPurchaseStore();
      var verified = 0, delivered = 0;
      final coordinator = PurchaseCoordinator(
        store: store,
        verify: (r) async {
          verified++;
          return Entitlement(
            status: 'active',
            productId: r.productId,
            expiresAt: DateTime.now().add(const Duration(days: 1)),
          );
        },
        deliver: (_) async {
          delivered++;
        },
        report: (_) {},
      );
      await store.buy('monthly', 'parent');
      await Future<void>.delayed(Duration.zero);
      await coordinator.settle();
      await store.restore();
      await Future<void>.delayed(Duration.zero);
      await coordinator.settle();
      expect(verified, 2);
      expect(delivered, 2);
      expect(store.completed, 2);
      await coordinator.dispose();
    },
  );
  test('Rejected receipts never unlock or acknowledge a purchase', () async {
    final store = SandboxPurchaseStore();
    var delivered = false;
    final coordinator = PurchaseCoordinator(
      store: store,
      verify: (_) async => throw StateError('Invalid receipt'),
      deliver: (_) async {
        delivered = true;
      },
      report: (_) {},
    );
    await store.buy('monthly', 'parent');
    await Future<void>.delayed(Duration.zero);
    await coordinator.settle();
    expect(delivered, isFalse);
    expect(store.completed, 0);
    await coordinator.dispose();
  });
  test(
    'Free access enforces direct routes while playtest preserves the approved library',
    () {
      final policy = AccessPolicy(playtest: false);
      expect(policy.allows('stories', {'access': 'sample'}), isTrue);
      expect(policy.allows('stories', {'access': 'library'}), isFalse);
      expect(policy.route('/science/colour-lab', (_, _) => {}), isFalse);
      expect(
        policy.route('/drawing/flower', (_, _) => {'access': 'sample'}),
        isTrue,
      );
      expect(
        policy.route('/drawing/premium', (_, _) => {'access': 'library'}),
        isFalse,
      );
      expect(AccessPolicy(playtest: true).allows('science', {}), isTrue);
    },
  );
}
