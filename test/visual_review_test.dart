import 'dart:io';
import 'dart:ui' as ui;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milo_and_me/core/brand.dart';
import 'package:milo_and_me/core/controller.dart';
import 'package:milo_and_me/data/database.dart';
import 'package:milo_and_me/data/content_repository.dart';
import 'package:milo_and_me/domain/models.dart';
import 'package:milo_and_me/features/world.dart';
import 'package:milo_and_me/features/onboarding.dart';
import 'package:milo_and_me/features/wardrobe.dart';
import 'package:milo_and_me/features/catalogues.dart';
import 'package:milo_and_me/features/drawing.dart';
import 'package:milo_and_me/features/puzzle.dart';
import 'package:milo_and_me/features/story.dart';
import 'package:milo_and_me/features/scenarios.dart';
import 'package:milo_and_me/features/memories.dart';
import 'package:milo_and_me/features/parent.dart';
import 'package:milo_and_me/features/science.dart';
import 'package:milo_and_me/ui/pet.dart';
import 'world_test.dart' show WorldUiController;

// Captures are review evidence, not self-approved golden baselines. Any Flutter
// layout/render exception fails CI. Real persistence is covered separately.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final flutterRoot =
        Platform.environment['FLUTTER_ROOT'] ??
        Platform.resolvedExecutable.split('/bin/cache/').first;
    final fonts = Directory('$flutterRoot/bin/cache/artifacts/material_fonts');
    final roboto = FontLoader('Roboto');
    for (final file in fonts.listSync().whereType<File>()) {
      if (file.path.endsWith('.ttf') && file.path.contains('Roboto-')) {
        roboto.addFont(
          file.readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
        );
      }
    }
    await roboto.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  const screens = <String, Widget>{
    'world': WorldScreen(),
    'world-studio': WorldScreen(),
    'world-stories': WorldScreen(),
    'world-play': WorldScreen(),
    'world-care': WorldScreen(),
    'world-garden': WorldScreen(),
    'onboarding': OnboardingScreen(),
    'wardrobe': WardrobeScreen(),
    'drawing-library': CatalogueScreen(kind: 'drawings'),
    'puzzle-library': CatalogueScreen(kind: 'puzzles'),
    'story-library': CatalogueScreen(kind: 'stories'),
    'drawing': DrawingScreen(id: 'flower'),
    'puzzle': PuzzleScreen(id: 'leaf-twin'),
    'moonlight': StoryScreen(id: 'missing-moonlight'),
    'moonlight-tree-ending': StoryScreen(id: 'missing-moonlight'),
    'moonlight-pond-ending': StoryScreen(id: 'missing-moonlight'),
    'cooking': ScenarioScreen(kind: 'cooking', id: 'pancakes'),
    'astronaut': ScenarioScreen(kind: 'roleplay', id: 'astronaut-mission'),
    'memories': MemoriesScreen(),
    'parent': ParentScreen(),
    'science': ScienceScreen(id: 'colour-lab'),
  };
  for (final device in [
    ('small', const Size(360, 640), 1.0),
    ('tall', const Size(430, 932), 1.0),
    ('tablet', const Size(1000, 900), 1.0),
    ('large-text', const Size(430, 932), 1.5),
  ]) {
    testWidgets('Visual review and overflow gate: ${device.$1}', (
      tester,
    ) async {
      tester.view.physicalSize = device.$2;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final entry in screens.entries) {
        final db = AppDatabase(NativeDatabase.memory());
        final content = ContentRepository(db);
        await tester.runAsync(() async {
          await content.load();
          for (final name in [
            'milo',
            'expressions',
            'props',
            'food',
            'pieces',
          ]) {
            await PetGame.texture(name);
          }
        });
        final world = World(
          onboarded: true,
          nickname: 'Acorn',
          reducedMotion: true,
        );
        if (entry.key.startsWith('world-')) {
          world.companion.area = entry.key.substring(6);
        }
        if (entry.key.endsWith('-ending')) {
          final ending = entry.key.substring('moonlight-'.length);
          world.storyPositions['missing-moonlight'] = ending;
          world.activities['story:missing-moonlight:$ending'] = {'done': true};
        }
        if (entry.key == 'memories' || entry.key == 'world-stories') {
          world.completedStories.add('missing-moonlight');
          world.companion.firsts.add('story');
          world.memories.add(
            Memory(
              id: 'story:missing-moonlight',
              kind: 'story',
              title: 'Milo and the Missing Moonlight',
              topic: 'kindness',
              at: DateTime(2026, 9, 11),
              payload: {'ending': 'pond-ending'},
            ),
          );
        }
        final app = WorldUiController(db, content, world);
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [controllerProvider.overrideWith((ref) => app)],
            child: MaterialApp(
              theme: Brand.theme().copyWith(
                textTheme: Brand.theme().textTheme.apply(fontFamily: 'Roboto'),
              ),
              home: Consumer(
                builder: (context, ref, child) {
                  ref.watch(controllerProvider);
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(device.$3)),
                    child: RepaintBoundary(
                      key: boundaryKey,
                      child: entry.value,
                    ),
                  );
                },
              ),
            ),
          ),
        );
        for (var frame = 0; frame < 3; frame++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 150)),
          );
          await tester.pump(const Duration(milliseconds: 400));
        }
        expect(
          tester.takeException(),
          isNull,
          reason: '${device.$1}/${entry.key}',
        );
        await tester.runAsync(() async {
          final boundary =
              boundaryKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            'build/visual-review/${device.$1}-${entry.key}.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.pumpWidget(const SizedBox());
      }
    });
  }
}
