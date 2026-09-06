import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milo_and_me/domain/engines.dart';
import 'package:milo_and_me/domain/models.dart';
import 'package:milo_and_me/data/database.dart';

void main() {
  final pack = Map<String, dynamic>.from(
    jsonDecode(File('assets/content/meadow.json').readAsStringSync()),
  );
  test('Core library meets every requested content count and theme', () {
    expect((pack['drawings'] as List).length, 24);
    expect((pack['puzzles'] as List).length, 55);
    expect((pack['stories'] as List).length, 12);
    for (final kind in ['drawings', 'puzzles', 'stories']) {
      expect(
        (pack[kind] as List).map((p) => p['theme']).toSet(),
        containsAll(['Dinosaurs', 'Space', 'Ocean', 'Animals', 'Nature']),
      );
    }
    ContentEngine.validate(pack);
  });
  test(
    'Every authored puzzle has a playable answer; incomplete answers fail',
    () {
      for (final raw in pack['puzzles']) {
        final p = Map<String, dynamic>.from(raw),
            answer = List<String>.from(raw['answer']);
        expect(PuzzleEngine().check(p, answer), isTrue, reason: p['id']);
        expect(
          PuzzleEngine().check(p, answer.take(answer.length - 1).toList()),
          isFalse,
          reason: p['id'],
        );
      }
    },
  );
  test('Malformed story props and remote audio paths are rejected', () {
    final broken = Map<String, dynamic>.from(jsonDecode(jsonEncode(pack)));
    broken['stories'][3]['scenes']['left']['interaction'] = {'label': 'touch'};
    expect(() => ContentEngine.validate(broken), throwsFormatException);
    broken['stories'][3]['scenes']['left'].remove('interaction');
    broken['stories'][3]['scenes']['left']['audio'] = 'audio/../../private';
    expect(() => ContentEngine.validate(broken), throwsFormatException);
  });
  test(
    'Drawing draft, chosen story branch and prop survive close and reopen',
    () async {
      final dir = await Directory.systemTemp.createTemp('milo-core');
      final file = File('${dir.path}/core.sqlite');
      var db = AppDatabase(NativeDatabase(file));
      final stroke = DrawingStroke(
        color: 0xff344a46,
        width: .02,
        points: [
          [.1, .2],
          [.4, .5],
        ],
      );
      await db.saveDraft('moon', {
        'strokes': [stroke.toJson()],
        'step': 2,
        'mode': 'Together',
      });
      final w = World(
        storyPositions: {'dino-shadow': 'left'},
        activities: {
          'story:dino-shadow:left': {'done': true},
        },
      );
      await db.saveWorld(w);
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      final draft = await db.readDraft('moon'), restored = await db.readWorld();
      expect(draft!['step'], 2);
      expect(DrawingStroke.fromJson(draft['strokes'][0]).points, stroke.points);
      expect(restored.storyPositions['dino-shadow'], 'left');
      expect(restored.activities['story:dino-shadow:left']!['done'], isTrue);
      await db.close();
      await dir.delete(recursive: true);
    },
  );
  test('Five puzzle families unlock one noncompetitive keepsake', () {
    var w = World();
    for (final family in ['match', 'sort', 'sequence', 'spatial', 'logic']) {
      w = MemoryEngine().add(
        w,
        Memory(
          id: family,
          kind: 'puzzle',
          title: family,
          topic: family,
          at: DateTime(2026),
          payload: {'engine': family, 'theme': 'Nature'},
        ),
      );
    }
    expect(w.companion.firsts, contains('puzzle-explorer'));
    expect(w.companion.firsts, contains('theme:Nature'));
    expect(w.companion.displaySlots.length, lessThanOrEqualTo(3));
  });
}
