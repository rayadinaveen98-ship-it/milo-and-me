import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milo_and_me/data/database.dart';
import 'package:milo_and_me/domain/models.dart';

void main(){
  test('SQLite fresh install, close/reopen and saved memory',()async{
    final dir=await Directory.systemTemp.createTemp('milo-db-test');
    final file=File('${dir.path}/world.sqlite');
    var db=AppDatabase(NativeDatabase(file));
    expect((await db.readWorld()).onboarded,isFalse);
    final w=World(onboarded:true,nickname:'Acorn',memories:[Memory(id:'m1',kind:'drawing',title:'Flower',topic:'flower',at:DateTime(2026),payload:{'strokes':[]})]);
    await db.saveWorld(w);await db.close();
    db=AppDatabase(NativeDatabase(file));
    expect((await db.readWorld()).memories.single.title,'Flower');
    expect((await db.readWorld()).nickname,'Acorn');
    await db.close();await dir.delete(recursive:true);
  });
  test('Promotion of a draft to a memory is atomic',()async{
    final db=AppDatabase(NativeDatabase.memory());
    await db.saveDraft('flower',{'strokes':[]});
    await db.saveWorld(World(nickname:'Friend'),removeDraft:'flower');
    expect(await db.readDraft('flower'),isNull);
    expect((await db.readWorld()).nickname,'Friend');await db.close();
  });
  test('Reset removes world, drafts, downloaded content and session',()async{
    final db=AppDatabase(NativeDatabase.memory());
    await db.saveWorld(World(nickname:'Acorn'));await db.saveDraft('flower',{'strokes':[]});
    await db.saveSession(300);await db.storePack({'id':'test','version':1});
    await db.reset();
    expect((await db.readWorld()).nickname,'');expect(await db.readDraft('flower'),isNull);
    expect(await db.packs(),isEmpty);expect(await db.readSession(),0);await db.close();
  });
  test('Opening schema v1 preserves existing state rather than re-creating it',()async{
    final dir=await Directory.systemTemp.createTemp('milo-migration-test');
    final file=File('${dir.path}/world.sqlite');
    var db=AppDatabase(NativeDatabase(file));await db.saveWorld(World(petName:'Sprout'));await db.close();
    db=AppDatabase(NativeDatabase(file));
    final version=await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single,1);expect((await db.readWorld()).petName,'Sprout');
    await db.close();await dir.delete(recursive:true);
  });
}
