import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:milo_and_me/data/database.dart';
import 'package:milo_and_me/data/content_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final pack = {
    'schema': 1,
    'id': 'ocean',
    'version': 1,
    'drawings': [],
    'puzzles': [],
    'stories': [],
  };
  final bytes = utf8.encode(jsonEncode(pack));
  test('A verified pack installs atomically and reloads offline', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = ContentRepository(
      db,
      clientFactory: () =>
          MockClient((_) async => http.Response.bytes(bytes, 200)),
    );
    await repo.load();
    await repo.download(
      url: Uri.parse('https://example.com/ocean.json'),
      expectedHash: sha256.convert(bytes).toString(),
      expectedId: 'ocean',
      expectedVersion: 1,
      progress: (_, __) {},
    );
    expect((await db.packs()).single['id'], 'ocean');
    final offline = ContentRepository(db);
    await offline.load();
    expect(offline.installed.single['id'], 'ocean');
    await db.close();
  });
  test('Corrupt pack never reaches active storage', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = ContentRepository(
      db,
      clientFactory: () =>
          MockClient((_) async => http.Response.bytes(bytes, 200)),
    );
    await repo.load();
    await expectLater(
      repo.download(
        url: Uri.parse('https://example.com/ocean.json'),
        expectedHash: List.filled(64, '0').join(),
        expectedId: 'ocean',
        expectedVersion: 1,
        progress: (_, __) {},
      ),
      throwsFormatException,
    );
    expect(await db.packs(), isEmpty);
    await db.close();
  });
  test('Network failure preserves existing downloaded content', () async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.storePack(pack);
    final repo = ContentRepository(
      db,
      clientFactory: () => MockClient((_) async => http.Response('', 503)),
    );
    await repo.load();
    await expectLater(
      repo.download(
        url: Uri.parse('https://example.com/ocean.json'),
        expectedHash: sha256.convert(bytes).toString(),
        expectedId: 'ocean',
        expectedVersion: 2,
        progress: (_, __) {},
      ),
      throwsStateError,
    );
    expect((await db.packs()).single['version'], 1);
    await db.close();
  });
}
