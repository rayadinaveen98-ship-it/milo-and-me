import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../domain/models.dart';

// Drift-managed SQLite, with explicit SQL migrations and no generated source.
class AppDatabase extends GeneratedDatabase {
  AppDatabase(QueryExecutor executor) : super(executor);
  static Future<AppDatabase> open() async {
    final directory = await getApplicationSupportDirectory();
    return AppDatabase(NativeDatabase.createInBackground(File(p.join(directory.path, 'milo.sqlite'))));
  }
  @override int get schemaVersion => 1;
  @override Iterable<TableInfo<Table, Object?>> get allTables => const [];
  @override List<DatabaseSchemaEntity> get allSchemaEntities => const [];
  @override MigrationStrategy get migration => MigrationStrategy(onCreate: (m) async {
    await customStatement('CREATE TABLE session (id INTEGER PRIMARY KEY CHECK(id=1), seconds INTEGER NOT NULL)');
    await customStatement('CREATE TABLE world (id INTEGER PRIMARY KEY CHECK(id=1), payload TEXT NOT NULL)');
    await customStatement('CREATE TABLE drawing_drafts (id TEXT PRIMARY KEY, payload TEXT NOT NULL)');
    await customStatement('CREATE TABLE packs (id TEXT PRIMARY KEY, version INTEGER NOT NULL, payload TEXT NOT NULL)');
  }, onUpgrade: (m, from, to) async {
    // Do not silently discard data when a later app adds a migration.
    throw StateError('Migration $from to $to has not been implemented');
  });
  Future<World> readWorld() async {
    final rows = await customSelect('SELECT payload FROM world WHERE id=1').get();
    if (rows.isEmpty) return World();
    return World.fromJson(jsonDecode(rows.single.read<String>('payload')));
  }
  Future<void> saveWorld(World world, {String? removeDraft}) => transaction(() async {
    if (removeDraft != null) await customStatement('DELETE FROM drawing_drafts WHERE id=?', [removeDraft]);
    await customStatement('INSERT INTO world(id,payload) VALUES(1,?) ON CONFLICT(id) DO UPDATE SET payload=excluded.payload', [jsonEncode(world.toJson())]);
  });
  Future<void> reset() => transaction(() async {
    await customStatement('DELETE FROM world');
    await customStatement('DELETE FROM session');
    await customStatement('DELETE FROM packs');
    await customStatement('DELETE FROM drawing_drafts');
  });
  Future<int> readSession() async {
    final rows = await customSelect('SELECT seconds FROM session WHERE id=1').get();
    return rows.isEmpty ? 0 : rows.single.read<int>('seconds');
  }
  Future<void> saveSession(int seconds) async {
    await customStatement('INSERT INTO session(id,seconds) VALUES(1,?) ON CONFLICT(id) DO UPDATE SET seconds=excluded.seconds', [seconds]);
  }
  Future<Json?> readDraft(String id) async {
    final rows = await customSelect('SELECT payload FROM drawing_drafts WHERE id=?', variables: [Variable<String>(id)]).get();
    return rows.isEmpty ? null : Map<String,dynamic>.from(jsonDecode(rows.single.read<String>('payload')));
  }
  Future<void> saveDraft(String id, Json payload) => transaction(() async {
    await customStatement('INSERT INTO drawing_drafts(id,payload) VALUES(?,?) ON CONFLICT(id) DO UPDATE SET payload=excluded.payload', [id, jsonEncode(payload)]);
  });
  Future<void> storePack(Json pack) => transaction(() async {
    await customStatement('INSERT INTO packs(id,version,payload) VALUES(?,?,?) ON CONFLICT(id) DO UPDATE SET version=excluded.version,payload=excluded.payload', [pack['id'], pack['version'], jsonEncode(pack)]);
  });
  Future<List<Json>> packs() async => (await customSelect('SELECT payload FROM packs').get())
    .map((r) => Map<String,dynamic>.from(jsonDecode(r.read<String>('payload')))).toList();
}
