import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:milo_and_me/core/audio.dart';
import 'package:milo_and_me/core/controller.dart';
import 'package:milo_and_me/data/database.dart';
import 'package:milo_and_me/data/content_repository.dart';
import 'package:milo_and_me/domain/engines.dart';
import 'package:milo_and_me/domain/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final pack = jsonDecode(
    File('assets/content/meadow.json').readAsStringSync(),
  );
  final story = Map<String, dynamic>.from(
    (pack['stories'] as List).firstWhere((s) => s['id'] == 'missing-moonlight'),
  );
  test(
    'Moonlight routes have distinct resolutions and every scene is interactive',
    () {
      ContentEngine.validate(Map<String, dynamic>.from(pack));
      final engine = StoryEngine();
      expect(engine.choose(story, 'opening', 0), 'tree');
      expect(engine.choose(story, 'opening', 1), 'pond');
      for (final scene in (story['scenes'] as Map).values) {
        expect(scene['interaction'], isA<Map>());
        expect((scene['text'] as String).split(' ').length, lessThan(30));
        expect(
          File('assets/${scene['audio']}').lengthSync(),
          greaterThan(1000),
        );
      }
      expect(engine.choose(story, 'firefly', 0), 'tree-ending');
      expect(engine.choose(story, 'cloud', 0), 'pond-ending');
      expect(
        File('assets/audio/moonlight-opening.mp3').lengthSync(),
        greaterThan(1000),
      );
    },
  );
  test(
    'Moonlight ending and interaction survive persistence and completion',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final app = AppController(
        db,
        ContentRepository(db),
        World(onboarded: true),
        audioOverride: SilentAudio(),
      );
      await app.storyPosition('missing-moonlight', 'pond-ending');
      await app.storyInteract('missing-moonlight', 'pond-ending');
      expect(
        (await db.readWorld())
            .activities['story:missing-moonlight:pond-ending']!['done'],
        true,
      );
      await app.completeStory(story);
      final saved = await db.readWorld();
      expect(saved.completedStories, contains('missing-moonlight'));
      expect(
        saved.memories
            .firstWhere((m) => m.id == 'story:missing-moonlight')
            .payload['ending'],
        'pond-ending',
      );
      app.dispose();
    },
  );
}
