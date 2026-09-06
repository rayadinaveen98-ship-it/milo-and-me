import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milo_and_me/core/controller.dart';
import 'package:milo_and_me/core/audio.dart';
import 'package:milo_and_me/data/database.dart';
import 'package:milo_and_me/data/content_repository.dart';
import 'package:milo_and_me/domain/models.dart';
import 'package:milo_and_me/domain/world_engine.dart';
import 'package:milo_and_me/features/world.dart';

void main(){
  test('Area and selected picture survive restart; decorations remain bounded',()async{
    final dir=await Directory.systemTemp.createTemp('milo-world');final file=File('${dir.path}/world.sqlite');
    var db=AppDatabase(NativeDatabase(file));final engine=WorldEngine();
    var w=World(memories:[for(var i=0;i<8;i++)Memory(id:'d$i',kind:'drawing',title:'Picture $i',topic:'art',at:DateTime(2026),payload:{'strokes':[]})]);
    w.companion.firsts.addAll(['drawing','puzzle','story','creativity-five','kindness']);
    w=engine.rotatePicture(engine.visit(w,'studio'));
    await db.saveWorld(w);await db.close();db=AppDatabase(NativeDatabase(file));
    final restored=await db.readWorld();expect(restored.companion.area,'studio');expect(engine.displayedPicture(restored)!.id,'d0');
    expect(engine.decorations(restored).length,3);expect(engine.displayedPicture(engine.rotatePicture(restored))!.id,'d1');
    expect(()=>engine.visit(restored,'unknown'),throwsArgumentError);
    await db.close();await dir.delete(recursive:true);
  });
  for(final size in [const Size(430,932),const Size(1000,900)]){
    testWidgets('Six world areas are reachable at ${size.width} pixels',(tester)async{
      tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
      final db=AppDatabase(NativeDatabase.memory());final content=ContentRepository(db);
      await tester.runAsync(content.load);
      final app=AppController(db,content,World(onboarded:true,reducedMotion:true),audioOverride:SilentAudio());
      await tester.pumpWidget(ProviderScope(overrides:[controllerProvider.overrideWith((ref)=>app)],child:const MaterialApp(home:WorldScreen())));
      for(final area in WorldEngine.areas){
        final button=find.byTooltip(WorldScreen.names[area]!);
        await tester.ensureVisible(button);
        await tester.runAsync(()async{await tester.tap(button);await app.change((w)=>w);});
        await tester.pump();await tester.pump(const Duration(milliseconds:300));
        expect(app.world.companion.area,area);expect(tester.takeException(),isNull);
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
}
