import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milo_and_me/main.dart';
import 'package:milo_and_me/core/audio.dart';
import 'package:milo_and_me/core/controller.dart';
import 'package:milo_and_me/data/database.dart';
import 'package:milo_and_me/data/content_repository.dart';
import 'package:milo_and_me/domain/models.dart';

void main(){
  testWidgets('Fresh install reaches the parent introduction',(tester)async{
    final db=AppDatabase(NativeDatabase.memory());final content=ContentRepository(db);
    // Asset loading and native SQLite initialization need real asynchronous I/O.
    await tester.runAsync(content.load);
    final app=AppController(db,content,World(),audioOverride:SilentAudio());
    await tester.pumpWidget(ProviderScope(overrides:[controllerProvider.overrideWith((ref)=>app)],child:const MiloApp()));
    await tester.pump(const Duration(milliseconds:100));
    expect(find.text('A little friend.\nA world to discover.'),findsOneWidget);
    await tester.ensureVisible(find.text('Let’s meet'));await tester.tap(find.text('Let’s meet'));await tester.pump();
    expect(find.text('A little note for grown-ups'),findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('Child can open art catalogue; parent settings require PIN',(tester)async{
    tester.view.physicalSize=const Size(430,932);tester.view.devicePixelRatio=1;
    addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
    final db=AppDatabase(NativeDatabase.memory());final content=ContentRepository(db);
    // Asset loading and native SQLite initialization need real asynchronous I/O.
    await tester.runAsync(content.load);
    final app=AppController(db,content,World(onboarded:true,nickname:'Acorn'),audioOverride:SilentAudio());
    await tester.pumpWidget(ProviderScope(overrides:[controllerProvider.overrideWith((ref)=>app)],child:const MiloApp()));await tester.pump();
    expect(find.text('Milo & Acorn'),findsOneWidget);
    await tester.tap(find.byTooltip('Art corner'));await tester.pump();await tester.pump(const Duration(seconds:1));await tester.pump();
    expect(find.text('The art corner'),findsOneWidget);
    await tester.tap(find.byTooltip('For grown-ups'));await tester.pump();await tester.pump(const Duration(seconds:1));await tester.pump();
    expect(find.text('Parent PIN'),findsOneWidget);expect(find.text('Delete local profile and creations'),findsNothing);
    expect(tester.takeException(),isNull);await tester.pumpWidget(const SizedBox());
  });
}
