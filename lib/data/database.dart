import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../domain/models.dart';

// Drift-managed SQLite, with explicit SQL migrations and no generated source.
class AppDatabase extends GeneratedDatabase {
  AppDatabase(super.executor);
  static Future<AppDatabase> open() async {
    final directory = await getApplicationSupportDirectory();
    return AppDatabase(
      NativeDatabase.createInBackground(
        File(p.join(directory.path, 'milo.sqlite')),
      ),
    );
  }

  @override
  int get schemaVersion => 2;
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await _createLargePayloadTables();
      await customStatement(
        'CREATE TABLE session (id INTEGER PRIMARY KEY CHECK(id=1), seconds INTEGER NOT NULL)',
      );
      await customStatement(
        'CREATE TABLE world (id INTEGER PRIMARY KEY CHECK(id=1), payload TEXT NOT NULL)',
      );
      await customStatement(
        'CREATE TABLE drawing_drafts (id TEXT PRIMARY KEY, payload TEXT NOT NULL)',
      );
      await customStatement(
        'CREATE TABLE packs (id TEXT PRIMARY KEY, version INTEGER NOT NULL, payload TEXT NOT NULL)',
      );
    },
    onUpgrade: (m, from, to) async {
      if (from == 1 && to == 2) {
        await _createLargePayloadTables();
        await saveWorld(await readWorld());
      } else {
        throw StateError('Migration $from to $to has not been implemented');
      }
    },
  );
  Future<void> _createLargePayloadTables() async {
    await customStatement('CREATE TABLE creations (id TEXT PRIMARY KEY, payload TEXT NOT NULL)');
    await customStatement('CREATE TABLE pack_media (pack_id TEXT NOT NULL, id TEXT NOT NULL, payload TEXT NOT NULL, PRIMARY KEY(pack_id,id))');
  }
  Future<Json?> readCreation(String id) async {
    final rows = await customSelect('SELECT payload FROM creations WHERE id=?', variables: [Variable<String>(id)]).get();
    return rows.isEmpty ? null : Map<String,dynamic>.from(jsonDecode(rows.single.read<String>('payload')));
  }
  Future<Json?> readMedia(String packId, String id) async {
    final rows = await customSelect('SELECT payload FROM pack_media WHERE pack_id=? AND id=?', variables: [Variable<String>(packId), Variable<String>(id)]).get();
    return rows.isEmpty ? null : Map<String,dynamic>.from(jsonDecode(rows.single.read<String>('payload')));
  }
  Future<void> removePack(String id) => transaction(() async {
    await customStatement('DELETE FROM packs WHERE id=?', [id]);
    await customStatement('DELETE FROM pack_media WHERE pack_id=?', [id]);
  });
  Future<World> readWorld() async {
    final rows = await customSelect(
      'SELECT payload FROM world WHERE id=1',
    ).get();
    if (rows.isEmpty) return World();
    return World.fromJson(jsonDecode(rows.single.read<String>('payload')));
  }

  Future<void> saveWorld(
    World world, {
    String? removeDraft,
  }) => transaction(() async {
    if (removeDraft != null) {
      await customStatement('DELETE FROM drawing_drafts WHERE id=?', [
        removeDraft,
      ]);
    }
    final json = world.toJson();
    for (final m in json['memories']) {
      if (m['kind'] == 'drawing' && m['payload']['strokes'] is List) {
        final payload = Map<String,dynamic>.from(m['payload']);
        await customStatement('INSERT INTO creations(id,payload) VALUES(?,?) ON CONFLICT(id) DO UPDATE SET payload=excluded.payload', [m['id'], jsonEncode(payload)]);
        m['payload'] = {'creationId': m['id'], if (payload['theme'] != null) 'theme': payload['theme']};
      }
    }
    await customStatement(
      'INSERT INTO world(id,payload) VALUES(1,?) ON CONFLICT(id) DO UPDATE SET payload=excluded.payload',
      [jsonEncode(json)],
    );
  });
  Future<void> reset() => transaction(() async {
    await customStatement('DELETE FROM creations');
    await customStatement('DELETE FROM pack_media');
    await customStatement('DELETE FROM world');
    await customStatement('DELETE FROM session');
    await customStatement('DELETE FROM packs');
    await customStatement('DELETE FROM drawing_drafts');
  });
  Future<int> readSession() async {
    final rows = await customSelect(
      'SELECT seconds FROM session WHERE id=1',
    ).get();
    return rows.isEmpty ? 0 : rows.single.read<int>('seconds');
  }

  Future<void> saveSession(int seconds) async {
    await customStatement(
      'INSERT INTO session(id,seconds) VALUES(1,?) ON CONFLICT(id) DO UPDATE SET seconds=excluded.seconds',
      [seconds],
    );
  }

  Future<Json?> readDraft(String id) async {
    final rows = await customSelect(
      'SELECT payload FROM drawing_drafts WHERE id=?',
      variables: [Variable<String>(id)],
    ).get();
    return rows.isEmpty
        ? null
        : Map<String, dynamic>.from(
            jsonDecode(rows.single.read<String>('payload')),
          );
  }

  Future<void> saveDraft(String id, Json payload) => transaction(() async {
    await customStatement(
      'INSERT INTO drawing_drafts(id,payload) VALUES(?,?) ON CONFLICT(id) DO UPDATE SET payload=excluded.payload',
      [id, jsonEncode(payload)],
    );
  });
  Future<void> storePack(Json pack) => transaction(() async {
    final stored = Map<String,dynamic>.from(pack);
    await customStatement('DELETE FROM pack_media WHERE pack_id=?', [pack['id']]);
    stored['media'] = <Json>[];
    for (final raw in (pack['media'] as List? ?? [])) {
      final media = Map<String,dynamic>.from(raw);
      await customStatement('INSERT INTO pack_media(pack_id,id,payload) VALUES(?,?,?)', [pack['id'], media['id'], jsonEncode(media)]);
      media.remove('data');
      (stored['media'] as List).add(media);
    }
    await customStatement(
      'INSERT INTO packs(id,version,payload) VALUES(?,?,?) ON CONFLICT(id) DO UPDATE SET version=excluded.version,payload=excluded.payload',
      [pack['id'], pack['version'], jsonEncode(stored)],
    );
  });
  Future<List<Json>> packs() async {
    final result = <Json>[];
    for (final r in await customSelect('SELECT payload FROM packs').get()) {
      try { result.add(Map<String,dynamic>.from(jsonDecode(r.read<String>('payload')))); }
      catch (_) { /* Quarantine malformed downloaded rows; bundled play survives. */ }
    }
    return result;
  }
}
