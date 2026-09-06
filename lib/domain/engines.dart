import 'models.dart';

class PetEngine {
  World care(World current, String action) {
    final next = current.copy();
    next.affection = (next.affection + 4).clamp(0, 100).toInt();
    switch (action) {
      case 'food': next.mood = 'eat'; next.dialogue = 'Crunch, crunch! A lovely little picnic.'; break;
      case 'wash': next.mood = 'wash'; next.dialogue = 'Pop! Those bubbles tickle.'; break;
      case 'sleep': next.mood = 'sleep'; next.energy = 100; next.dialogue = 'A quiet moment. You can rest too.'; break;
      default: next.mood = 'happy'; next.dialogue = 'My favourite part is making things with you!';
    }
    return next;
  }
  String suggestion(World w, {required int hour, required int sessionMinutes}) {
    if (sessionMinutes >= w.sessionMinutes) { return 'What a lovely adventure. Shall we make something on paper now?'; }
    if (w.outfit == 'astronaut') { return 'Our space helmet is ready. Shall we visit the little star?'; }
    if (w.memories.isNotEmpty) { return 'Remember our ${w.memories.last.topic}? It has a home on our memory shelf.'; }
    if (hour >= 19 || hour < 6) { return 'The stars are out. A gentle story together?'; }
    return 'What shall we discover? My easel is ready for a picture!';
  }
}
class MemoryEngine {
  World add(World current, Memory memory) {
    final next = current.copy();
    if (next.memories.any((m) => m.id == memory.id)) { return next; }
    next.memories.add(memory);
    next.mood = 'happy';
    next.dialogue = 'Our ${memory.topic}! Let’s keep this lovely memory.';
    next.affection = (next.affection + 5).clamp(0, 100).toInt();
    if (memory.kind == 'drawing') next.owned.add('beret');
    if (memory.kind == 'puzzle') next.owned.add('explorer');
    if (memory.kind == 'story') next.owned.add('astronaut');
    return next;
  }
}
class PuzzleEngine {
  bool check(Json definition, List<String> answer) {
    final expected = List<String>.from(definition['answer']);
    return answer.length == expected.length &&
      List.generate(answer.length, (i) => answer[i] == expected[i]).every((v) => v);
  }
}
class StoryEngine {
  Json scene(Json story, String? position) {
    final scenes = Map<String, dynamic>.from(story['scenes']);
    return Map<String,dynamic>.from(scenes[position] ?? scenes[story['start']]);
  }
  String choose(Json story, String position, int choice) {
    final current = scene(story, position);
    final choices = current['choices'] as List;
    if (choice < 0 || choice >= choices.length) throw RangeError.index(choice, choices);
    final next = choices[choice]['next'] as String;
    if (!(story['scenes'] as Map).containsKey(next)) throw const FormatException('Missing scene');
    return next;
  }
}
class ContentEngine {
  static void validate(Json pack) {
    if (pack['schema'] != 1 || pack['id'] is! String || pack['version'] is! int || (pack['version'] as int) < 1) {
      throw const FormatException('This pack needs a newer app or has invalid metadata.');
    }
    final ids = <String>{};
    for (final type in ['drawings', 'puzzles', 'stories']) {
      if (pack[type] is! List || (pack[type] as List).length > 200) throw const FormatException('Invalid catalogue');
      for (final raw in pack[type]) {
        final item = Map<String,dynamic>.from(raw);
        if (item['id'] is! String || !ids.add(item['id']) || item['title'] is! String || item['topic'] is! String || !RegExp(r'^[a-z0-9][a-z0-9_-]{0,63}$').hasMatch(item['id'])) {
          throw const FormatException('Missing or duplicate content identity');
        }
        if (type == 'drawings') {
          if (item['steps'] is! List || (item['steps'] as List).isEmpty || (item['steps'] as List).length > 64) throw const FormatException('Empty lesson');
          for (final step in item['steps']) {
            if (step['say'] is! String || step['points'] is! List || (step['points'] as List).length < 2 || (step['points'] as List).length > 2048) throw const FormatException('Invalid stroke');
            for (final point in step['points']) {
              if (point is! List || point.length != 2 || point.any((v) => v is! num || !v.isFinite || v < 0 || v > 1)) throw const FormatException('Invalid point');
            }
          }
        }
        if (type == 'puzzles') {
          if (!['match', 'sort', 'sequence', 'spatial', 'logic'].contains(item['engine']) || item['prompt'] is! String || item['options'] is! List || item['answer'] is! List || (item['answer'] as List).isEmpty || (item['options'] as List).length < 2 || (item['options'] as List).length > 12 || (item['options'] as List).any((v) => v is! String) || (item['answer'] as List).length > 8) throw const FormatException('Invalid puzzle');
          if ((item['answer'] as List).any((v) => !(item['options'] as List).contains(v))) throw const FormatException('Unsolvable puzzle');
        }
        if (type == 'stories') {
          final scenes = item['scenes'];
          if (scenes is! Map || scenes.length > 100 || !scenes.containsKey(item['start'])) throw const FormatException('Invalid story');
          final reachable = <String>{};
          void visit(String id) {
            if (!reachable.add(id)) return;
            final scene = scenes[id];
            if (scene is! Map || scene['text'] is! String || scene['choices'] is! List) throw const FormatException('Invalid scene');
            for (final choice in scene['choices']) {
              if (choice['label'] is! String || !scenes.containsKey(choice['next'])) throw const FormatException('Broken story branch');
              visit(choice['next']);
            }
          }
          visit(item['start']);
          final canEnd = <String>{for (final id in reachable) if ((scenes[id]['choices'] as List).isEmpty) id};
          var changed = true;
          while (changed) {
            changed = false;
            for (final id in reachable) {
              if (!canEnd.contains(id) && (scenes[id]['choices'] as List).any((c) => canEnd.contains(c['next']))) { canEnd.add(id); changed = true; }
            }
          }
          if (canEnd.length != reachable.length) throw const FormatException('Story cannot finish');
        }
      }
    }
  }
}
