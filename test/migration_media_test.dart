import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:milo_and_me/data/database.dart';
import 'package:milo_and_me/data/content_repository.dart';
import 'package:milo_and_me/domain/models.dart';
import 'package:milo_and_me/domain/pack_media.dart';

class LegacyDatabase extends AppDatabase {
  LegacyDatabase(super.executor);
  @override int get schemaVersion => 1;
  @override MigrationStrategy get migration => MigrationStrategy(onCreate:(m) async {
    await customStatement('CREATE TABLE world (id INTEGER PRIMARY KEY, payload TEXT NOT NULL)');
    await customStatement('CREATE TABLE session (id INTEGER PRIMARY KEY, seconds INTEGER NOT NULL)');
    await customStatement('CREATE TABLE drawing_drafts (id TEXT PRIMARY KEY, payload TEXT NOT NULL)');
    await customStatement('CREATE TABLE packs (id TEXT PRIMARY KEY, version INTEGER NOT NULL, payload TEXT NOT NULL)');
  });
}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Actual schema-1 upgrade moves artwork atomically and preserves all progress', () async {
    final dir=await Directory.systemTemp.createTemp('milo-v1'); final file=File('${dir.path}/world.sqlite');
    final old=LegacyDatabase(NativeDatabase(file));
    final w=World(nickname:'Friend',petName:'Sprout',memories:[Memory(id:'art',kind:'drawing',title:'Flower',topic:'flower',at:DateTime(2026),payload:{'strokes':[],'thumbnail':'original'})]);
    await old.customStatement('INSERT INTO world VALUES(1,?)',[jsonEncode(w.toJson())]);
    await old.saveDraft('draft',{'strokes':[]}); await old.saveSession(42); await old.close();
    final db=AppDatabase(NativeDatabase(file)); final restored=await db.readWorld();
    expect(restored.nickname,'Friend'); expect(restored.petName,'Sprout');
    expect(restored.memories.single.payload,{'creationId':'art'});
    expect((await db.readCreation('art'))!['thumbnail'],'original');
    expect(await db.readDraft('draft'),isNotNull); expect(await db.readSession(),42);
    await db.saveWorld(restored); expect((await db.readCreation('art'))!['thumbnail'],'original');
    await db.reset(); expect(await db.readCreation('art'),isNull);
    await db.close(); await dir.delete(recursive:true);
  });
  test('Pack media verifies, installs atomically, reloads lazily offline and uninstalls', () async {
    final bytes=File('assets/audio/reward.wav').readAsBytesSync();
    final pack={'schema':1,'id':'media-test','version':1,'manifest':{'schema':1,'id':'media-test','version':1,'language':'en'},'drawings':[],'puzzles':[],'stories':[],'media':[{'id':'voice','mime':'audio/wav','bytes':bytes.length,'sha256':sha256.convert(bytes).toString(),'data':base64Encode(bytes)}]};
    final data=utf8.encode(jsonEncode(pack));
    final db=AppDatabase(NativeDatabase.memory());
    final repo=ContentRepository(db,clientFactory:()=>MockClient((_) async=>http.Response.bytes(data,200)));
    await repo.load();
    await repo.download(url:Uri.parse('https://fixture.test/pack'),expectedHash:sha256.convert(data).toString(),expectedId:'media-test',expectedVersion:1,progress:(_,_){});
    expect(repo.installed.single['media'][0].containsKey('data'),isFalse);
    final offline=ContentRepository(db); await offline.load();
    expect(await offline.mediaBytes('pack:media-test:voice'),bytes);
    await expectLater(repo.download(url:Uri.parse('https://fixture.test/pack'),expectedHash:sha256.convert(data).toString(),expectedId:'media-test',expectedVersion:1,progress:(_,_){}),throwsFormatException);
    await offline.uninstall('media-test'); expect(await db.readMedia('media-test','voice'),isNull); await db.close();
  });
  test('Corrupt downloaded metadata cannot prevent bundled offline startup', () async {
    final db=AppDatabase(NativeDatabase.memory());
    await db.storePack({'id':'bad','version':1,'schema':99});
    final repo=ContentRepository(db); await repo.load();
    expect(repo.installed,isEmpty); expect(repo.list('drawings').length,24); await db.close();
  });
  test('Manifest identity and missing media references are rejected', () {
    expect(()=>PackMedia.validate({'id':'a','version':1,'manifest':{'schema':1,'id':'other','version':1,'language':'en'}}),throwsFormatException);
    expect(()=>PackMedia.validate({'drawings':[{'audio':'pack:a:missing'}]}),throwsFormatException);
  });
}
