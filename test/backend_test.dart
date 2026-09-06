import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:milo_and_me/data/parent_backend.dart';

void main() {
  test('Entitlement expiry is exclusive and revoked access is not active', () {
    final expiry = DateTime.utc(2026, 9, 7);
    expect(
      Entitlement(
        status: 'active',
        productId: 'annual',
        expiresAt: expiry,
      ).validAt(expiry),
      isFalse,
    );
    expect(
      Entitlement(
        status: 'revoked',
        productId: 'annual',
        expiresAt: expiry,
      ).validAt(DateTime.utc(2026, 9, 6)),
      isFalse,
    );
  });
  test(
    'Parent adapter sends parent authorization and reads catalogue',
    () async {
      final client = MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer parent-token');
        expect(request.url.path, '/rest/v1/content_packs');
        return http.Response('[{"id":"space","version":1}]', 200);
      });
      final backend = SupabaseParentBackend(
        base: Uri.parse('https://example.supabase.co'),
        publishableKey: 'public-test',
        accessToken: () async => 'parent-token',
        client: client,
      );
      expect((await backend.catalogue()).single['id'], 'space');
      client.close();
    },
  );
  test(
    'Expired parent session does not become a fake offline success',
    () async {
      final client = MockClient((r) async => http.Response('', 401));
      final backend = SupabaseParentBackend(
        base: Uri.parse('https://example.supabase.co'),
        publishableKey: 'public-test',
        accessToken: () async => 'expired',
        client: client,
      );
      await expectLater(backend.entitlement(), throwsStateError);
      client.close();
    },
  );
}
