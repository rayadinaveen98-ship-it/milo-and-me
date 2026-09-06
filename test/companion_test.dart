import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milo_and_me/domain/models.dart';
import 'package:milo_and_me/domain/engines.dart';
import 'package:milo_and_me/data/database.dart';

void main() {
  final now=DateTime(2026,9,6,12);
  test('Care repetition is bounded and never repeats adjacent dialogue', () {
    var world=World();
    final lines=<String>[];
    for(var i=0;i<20;i++) {
      world=PetEngine().care(world,'cuddle',now:now);
      if(lines.isNotEmpty) expect(world.dialogue,isNot(lines.last));
      lines.add(world.dialogue);
    }
    expect(lines.toSet().length,3);
    expect(world.companion.recentLines.length,lessThanOrEqualTo(6));
  });
  test('Three activity families create distinct callbacks and display slots', () {
    var w=World();
    for(final kind in ['drawing','puzzle','story']) {
      w=MemoryEngine().add(w,Memory(id:kind,kind:kind,title:kind,topic:'$kind topic',at:now));
    }
    final lines=<String>[];
    for(var i=0;i<60;i++) {
      w=PetEngine().react(w,now:now,sessionMinutes:0);lines.add(w.dialogue);
    }
    for(final kind in ['drawing','puzzle','story']) {
      expect(lines.any((l)=>l.contains('$kind topic')),isTrue);
    }
    expect(w.companion.displaySlots,{'picture':'drawing','puzzle':'puzzle','story':'story'});
    expect(w.companion.stage,'adventure-friends');
    expect(w.companion.favourites['drawing'],1);
  });
  test('Long absence greetings preserve energy and affection', () {
    final w=World(energy:70,affection:80);
    w.companion.lastInteraction=now.subtract(const Duration(days:365));
    final greeting=PetEngine().greet(w,now);
    expect(greeting.energy,70);expect(greeting.affection,80);
    expect(greeting.companion.lastSession,now);
    expect(greeting.dialogue,isNot(contains('missed')));
  });
  test('Legacy payload migrates without losing picture or progress', () {
    final old=World(nickname:'Acorn',outfit:'scarf',memories:[Memory(id:'art',kind:'drawing',title:'Fish',topic:'fish',at:now)]).toJson();
    old['schema']=1;old.remove('companion');
    final restored=World.fromJson(jsonDecode(jsonEncode(old)));
    expect(restored.nickname,'Acorn');expect(restored.memories.single.title,'Fish');
    expect(restored.companion.displaySlots['picture'],'art');
    expect(restored.toJson()['schema'],2);
  });
  test('Companion, outfit and keepsakes survive a database restart offline', () async {
    final dir=await Directory.systemTemp.createTemp('milo-companion');
    final file=File('${dir.path}/world.sqlite');
    var db=AppDatabase(NativeDatabase(file));
    var w=MemoryEngine().add(World(outfit:'scarf'),Memory(id:'art',kind:'drawing',title:'Fish',topic:'fish',at:now));
    w=PetEngine().care(w,'wash',now:now);
    await db.saveWorld(w);await db.close();
    db=AppDatabase(NativeDatabase(file));
    final restored=await db.readWorld();
    expect(restored.companion.toJson(),w.companion.toJson());
    expect(restored.outfit,'scarf');expect(restored.memories.single.id,'art');
    await db.close();await dir.delete(recursive:true);
  });
}
