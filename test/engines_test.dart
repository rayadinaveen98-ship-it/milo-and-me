import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:milo_and_me/domain/models.dart';
import 'package:milo_and_me/domain/engines.dart';

void main() {
  final pack = Map<String, dynamic>.from(
    jsonDecode(File('assets/content/meadow.json').readAsStringSync()),
  );
  test(
    'Every authored content item passes runtime validation',
    () => ContentEngine.validate(pack),
  );
  test('Memory is idempotent and unlocks only its activity reward', () {
    final original = World();
    final memory = Memory(
      id: 'drawing:first',
      kind: 'drawing',
      title: 'Flower',
      topic: 'flower',
      at: DateTime(2026),
    );
    final next = MemoryEngine().add(original, memory);
    expect(original.memories, isEmpty);
    expect(next.owned, contains('beret'));
    expect(next.owned, isNot(contains('astronaut')));
    expect(MemoryEngine().add(next, memory).memories.length, 1);
  });
  test('Pet care never damages wellbeing or uses absence penalties', () {
    final pet = PetEngine();
    for (final action in ['food', 'wash', 'sleep', 'cuddle']) {
      final next = pet.care(World(affection: 98), action);
      expect(next.affection, 100);
      expect(next.energy, greaterThanOrEqualTo(80));
      expect(next.dialogue, isNot(contains('left me')));
    }
  });
  test('Session ending takes precedence over outfit suggestions', () {
    final w = World(outfit: 'astronaut', sessionMinutes: 10);
    expect(
      PetEngine().suggestion(w, hour: 12, sessionMinutes: 10),
      contains('paper'),
    );
  });
  test('Pet remembers a real topic and space outfit affects suggestions', () {
    final w = World(
      memories: [
        Memory(
          id: 'one',
          kind: 'drawing',
          title: 'Fish',
          topic: 'fish',
          at: DateTime(2026),
        ),
      ],
    );
    expect(
      PetEngine().suggestion(w, hour: 12, sessionMinutes: 0),
      contains('fish'),
    );
    w.outfit = 'astronaut';
    expect(
      PetEngine().suggestion(w, hour: 12, sessionMinutes: 0),
      contains('space'),
    );
  });
  test('Puzzle ordering and length are checked, not just membership', () {
    final puzzle = Map<String, dynamic>.from(
      (pack['puzzles'] as List).firstWhere((p) => p['id'] == 'bridge'),
    );
    expect(PuzzleEngine().check(puzzle, ['■', '▲', '■']), isTrue);
    expect(PuzzleEngine().check(puzzle, ['▲', '■', '■']), isFalse);
    expect(PuzzleEngine().check(puzzle, ['■', '▲']), isFalse);
  });
  test('Story branching follows the chosen branch', () {
    final story = Map<String, dynamic>.from(pack['stories'][0]);
    expect(StoryEngine().choose(story, 'start', 0), 'trail');
    expect(StoryEngine().choose(story, 'start', 1), 'moon');
    expect(() => StoryEngine().choose(story, 'start', 99), throwsRangeError);
  });
  test('A corrupt story target is rejected', () {
    final bad = Map<String, dynamic>.from(jsonDecode(jsonEncode(pack)));
    bad['stories'][0]['scenes']['start']['choices'][0]['next'] = 'missing';
    expect(() => ContentEngine.validate(bad), throwsFormatException);
  });
  test('A branch trapped in a cycle is rejected', () {
    final bad = Map<String, dynamic>.from(jsonDecode(jsonEncode(pack)));
    bad['stories'][0]['scenes']['home']['choices'] = [
      {'label': 'Again', 'next': 'home'},
    ];
    expect(() => ContentEngine.validate(bad), throwsFormatException);
  });
  test('Normalized drawing strokes round-trip including eraser', () {
    final stroke = DrawingStroke(
      color: 0xff344a46,
      width: .02,
      erase: true,
      points: [
        [.1, .2],
        [.3, .4],
      ],
    );
    final roundTrip = DrawingStroke.fromJson(
      jsonDecode(jsonEncode(stroke.toJson())),
    );
    expect(roundTrip.erase, isTrue);
    expect(roundTrip.points, stroke.points);
  });
  test('Unknown save versions fail without silently resetting creations', () {
    final bad = World().toJson()..['schema'] = 999;
    expect(() => World.fromJson(bad), throwsFormatException);
  });
}
