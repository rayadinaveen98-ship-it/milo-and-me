import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milo_and_me/domain/models.dart';
import 'package:milo_and_me/domain/engines.dart';
import 'package:milo_and_me/domain/scenario_engine.dart';
import 'package:milo_and_me/data/database.dart';

void main() {
  final pack = Map<String, dynamic>.from(
    jsonDecode(File('assets/content/meadow.json').readAsStringSync()),
  );
  final engine = ScenarioEngine();
  test(
    'Five recipes and all six roleplay themes are reusable and finishable',
    () {
      expect((pack['cooking'] as List).length, 5);
      expect((pack['roleplay'] as List).length, 6);
      for (final kind in ['cooking', 'roleplay'])
        for (final raw in pack[kind]) {
          final definition = Map<String, dynamic>.from(raw);
          ScenarioEngine.validate(definition);
          var world = World();
          var now = DateTime(2026);
          for (
            var i = 0;
            i < 100 &&
                !engine.complete(
                  definition,
                  engine.progress(world, kind, definition['id']),
                );
            i++
          ) {
            final p = engine.progress(world, kind, definition['id']);
            final step = definition['steps'][p['index']];
            now = now.add(const Duration(seconds: 6));
            world = engine.perform(
              world,
              kind,
              definition,
              step['options'][0],
              now: now,
            );
          }
          expect(
            engine.complete(
              definition,
              engine.progress(world, kind, definition['id']),
            ),
            isTrue,
            reason: definition['id'],
          );
        }
      ContentEngine.validate(pack);
    },
  );
  test('Malformed actions and unknown choices cannot advance', () {
    final bad = Map<String, dynamic>.from(
      jsonDecode(jsonEncode(pack['cooking'][0])),
    );
    bad['steps'][0]['action'] = 'real-flame';
    expect(() => ScenarioEngine.validate(bad), throwsFormatException);
    final good = Map<String, dynamic>.from(pack['cooking'][0]);
    expect(
      () => engine.perform(World(), 'cooking', good, 'not-an-option'),
      throwsFormatException,
    );
  });
  test(
    'Pretend timing waits for its bounded interval without a failure penalty',
    () {
      final definition = {
        'id': 'timer',
        'title': 'Timer',
        'topic': 'timer',
        'steps': [
          {
            'action': 'choose',
            'prompt': 'Start',
            'symbol': '○',
            'options': ['start'],
          },
          {
            'action': 'timing',
            'prompt': 'Wait',
            'symbol': '○',
            'options': ['ready'],
            'seconds': 2,
          },
        ],
      };
      final now = DateTime(2026);
      final w = engine.perform(
        World(),
        'cooking',
        definition,
        'start',
        now: now,
      );
      expect(
        () => engine.perform(w, 'cooking', definition, 'ready', now: now),
        throwsFormatException,
      );
      expect(w.energy, 80);
      expect(
        engine.complete(
          definition,
          engine.progress(
            engine.perform(
              w,
              'cooking',
              definition,
              'ready',
              now: now.add(const Duration(seconds: 3)),
            ),
            'cooking',
            'timer',
          ),
        ),
        isTrue,
      );
    },
  );
  test(
    'Cooking step and chosen ingredient survive a real database restart',
    () async {
      final dir = await Directory.systemTemp.createTemp('milo-play');
      final file = File('${dir.path}/play.sqlite');
      var db = AppDatabase(NativeDatabase(file));
      final recipe = Map<String, dynamic>.from(pack['cooking'][0]);
      final w = engine.perform(World(), 'cooking', recipe, 'Oat flour');
      await db.saveWorld(w);
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      final restored = await db.readWorld();
      expect(engine.progress(restored, 'cooking', 'pancakes')['index'], 1);
      expect(engine.progress(restored, 'cooking', 'pancakes')['choices'], [
        'Oat flour',
      ]);
      await db.close();
      await dir.delete(recursive: true);
    },
  );
  test('Cooking and pretend milestones unlock only their intended costume', () {
    final now = DateTime(2026);
    final cook = MemoryEngine().add(
      World(),
      Memory(
        id: 'recipe',
        kind: 'cooking',
        title: 'Pancakes',
        topic: 'picnic',
        at: now,
      ),
    );
    expect(cook.owned, contains('chef'));
    expect(cook.owned, isNot(contains('doctor')));
    final pretend = MemoryEngine().add(
      cook,
      Memory(
        id: 'toy',
        kind: 'roleplay',
        title: 'Teddy',
        topic: 'toy care',
        at: now,
        payload: {'outfit': 'doctor'},
      ),
    );
    expect(pretend.owned, contains('doctor'));
    expect(
      MemoryEngine().add(pretend, pretend.memories.last).memories.length,
      2,
    );
  });
}
