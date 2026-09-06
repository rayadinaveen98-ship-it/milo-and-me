import 'models.dart';

class PetEngine {
  World care(World current, String action, {DateTime? now}) {
    final next = current.copy();
    next.affection = (next.affection + 4).clamp(0, 100).toInt();
    final lines = switch (action) {
      'food' => [
        'Crunch, crunch! A lovely little picnic.',
        'A picnic tastes better together.',
        'Thank you! Shall we pretend these are moon apples?',
      ],
      'wash' => [
        'Pop! Those bubbles tickle.',
        'A tiny bubble parade!',
        'Look, a round rainbow!',
      ],
      'sleep' => [
        'A quiet moment. You can rest too.',
        'Our adventures will be here after a rest.',
        'Let’s get cosy.',
      ],
      _ => [
        'My favourite part is making things with you!',
        'A little cuddle, a lovely moment.',
        'I’m glad we are friends.',
      ],
    };
    next.mood = switch (action) {
      'food' => 'eat',
      'wash' => 'wash',
      'sleep' => 'sleep',
      _ => 'affection',
    };
    next.companion.careState = switch (action) {
      'food' => 'fed',
      'wash' => 'fresh',
      'sleep' => 'rested',
      _ => 'comfortable',
    };
    if (action == 'sleep') next.energy = 100;
    _speak(next, lines, now ?? DateTime.now());
    return next;
  }

  void _speak(World w, List<String> candidates, DateTime now) {
    final c = w.companion;
    final fresh = candidates
        .where((line) => !c.recentLines.contains(line))
        .toList();
    final pool = fresh.isNotEmpty
        ? fresh
        : candidates.where((line) => line != w.dialogue).toList();
    w.dialogue = pool.isEmpty ? candidates.first : pool[c.cursor % pool.length];
    c.cursor++;
    c.interactions++;
    c.lastInteraction = now;
    c.recentLines.add(w.dialogue);
    if (c.recentLines.length > 6) c.recentLines.removeAt(0);
  }

  World greet(World current, DateTime now) {
    final w = current.copy(), c = current.companion;
    final returning =
        c.lastInteraction != null &&
        now.difference(c.lastInteraction!).inHours >= 6;
    _speak(
      w,
      returning
          ? [
              'Welcome back, ${w.nickname}! Our little world is ready.',
              'Hello again! Shall we make a new memory?',
              'Lovely to see you. A gentle adventure today?',
            ]
          : [
              'Hello, ${w.nickname}! What shall we discover?',
              'A little time together. What do you fancy?',
              'Our play space is ready for imagination.',
            ],
      now,
    );
    w.companion.lastSession = now;
    w.mood = 'happy';
    return w;
  }

  World react(
    World current, {
    required DateTime now,
    required int sessionMinutes,
  }) {
    final w = current.copy();
    final candidates = <String>[];
    if (sessionMinutes >= w.sessionMinutes) {
      candidates.addAll([
        'Shall we draw together on paper?',
        'Perhaps we could look for a leaf shape outside with a grown-up.',
        'Our adventures can wait. A little stretch together?',
      ]);
    } else {
      if (w.outfit == 'astronaut') {
        candidates.add(
          'Our space helmet is ready. Shall we visit the little star?',
        );
      }
      if (w.outfit == 'beret') {
        candidates.add('Our artist hat is ready for a colourful idea.');
      }
      if (w.outfit == 'explorer') {
        candidates.add('What could we discover in our puzzle box?');
      }
      // An occasional callback: never recite dates or a detailed activity log.
      if (w.companion.cursor % 3 == 0) {
        for (final kind in ['drawing', 'puzzle', 'story']) {
          final items = w.memories.where((m) => m.kind == kind).toList();
          if (items.isNotEmpty) {
            candidates.add(
              'Remember our ${items.last.topic}? I loved exploring that with you.',
            );
          }
        }
      }
      candidates.addAll(
        now.hour >= 19 || now.hour < 6
            ? [
                'The stars are out. A gentle story together?',
                'Our cosy room is a lovely place to imagine.',
              ]
            : [
                'Shall we try a new colour at the easel?',
                'I wonder what is inside our story book.',
                'Shall we solve a little mystery together?',
                'We could make something, or just sit together.',
              ],
      );
    }
    _speak(w, candidates, now);
    w.mood = w.companion.cursor % 2 == 0 ? 'curious' : 'happy';
    return w;
  }

  String suggestion(World w, {required int hour, required int sessionMinutes}) {
    if (sessionMinutes >= w.sessionMinutes) {
      return 'What a lovely adventure. Shall we make something on paper now?';
    }
    if (w.outfit == 'astronaut') {
      return 'Our space helmet is ready. Shall we visit the little star?';
    }
    if (w.memories.isNotEmpty) {
      return 'Remember our ${w.memories.last.topic}? It has a home on our memory shelf.';
    }
    if (hour >= 19 || hour < 6) {
      return 'The stars are out. A gentle story together?';
    }
    return 'What shall we discover? My easel is ready for a picture!';
  }
}

class MemoryEngine {
  World add(World current, Memory memory) {
    final next = current.copy();
    if (next.memories.any((m) => m.id == memory.id)) {
      return next;
    }
    next.memories.add(memory);
    next.companion.remember(memory);
    if(next.memories.where((m)=>m.kind=='drawing').length>=5) next.companion.firsts.add('creativity-five');
    if(next.memories.where((m)=>m.kind=='puzzle').map((m)=>m.payload['engine']).whereType<String>().toSet().length==5) next.companion.firsts.add('puzzle-explorer');
    final theme=memory.payload['theme'];
    if(theme is String && next.memories.where((m)=>m.payload['theme']==theme).length>=3) next.companion.firsts.add('theme:$theme');
    if(memory.payload['milestone']=='kindness')next.companion.firsts.add('kindness');
    next.mood = 'dance';
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
        List.generate(
          answer.length,
          (i) => answer[i] == expected[i],
        ).every((v) => v);
  }
}

class StoryEngine {
  Json scene(Json story, String? position) {
    final scenes = Map<String, dynamic>.from(story['scenes']);
    return Map<String, dynamic>.from(
      scenes[position] ?? scenes[story['start']],
    );
  }

  String choose(Json story, String position, int choice) {
    final current = scene(story, position);
    final choices = current['choices'] as List;
    if (choice < 0 || choice >= choices.length) {
      throw RangeError.index(choice, choices);
    }
    final next = choices[choice]['next'] as String;
    if (!(story['scenes'] as Map).containsKey(next)) {
      throw const FormatException('Missing scene');
    }
    return next;
  }
}

class ContentEngine {
  static void validate(Json pack) {
    if (pack['schema'] != 1 ||
        pack['id'] is! String ||
        pack['version'] is! int ||
        (pack['version'] as int) < 1) {
      throw const FormatException(
        'This pack needs a newer app or has invalid metadata.',
      );
    }
    final ids = <String>{};
    for (final type in ['drawings', 'puzzles', 'stories']) {
      if (pack[type] is! List || (pack[type] as List).length > 200) {
        throw const FormatException('Invalid catalogue');
      }
      for (final raw in pack[type]) {
        final item = Map<String, dynamic>.from(raw);
        if (item['id'] is! String ||
            !ids.add(item['id']) ||
            item['title'] is! String ||
            item['topic'] is! String ||
            !RegExp(r'^[a-z0-9][a-z0-9_-]{0,63}$').hasMatch(item['id'])) {
          throw const FormatException('Missing or duplicate content identity');
        }
        if(item['theme']!=null && !['Dinosaurs','Space','Ocean','Animals','Nature'].contains(item['theme'])) throw const FormatException('Unknown theme');
        if (type == 'drawings') {
          if (item['steps'] is! List ||
              (item['steps'] as List).isEmpty ||
              (item['steps'] as List).length > 64) {
            throw const FormatException('Empty lesson');
          }
          for (final step in item['steps']) {
            if (step['say'] is! String ||
                step['points'] is! List ||
                (step['points'] as List).length < 2 ||
                (step['points'] as List).length > 2048) {
              throw const FormatException('Invalid stroke');
            }
            for (final point in step['points']) {
              if (point is! List ||
                  point.length != 2 ||
                  point.any(
                    (v) => v is! num || !v.isFinite || v < 0 || v > 1,
                  )) {
                throw const FormatException('Invalid point');
              }
            }
          }
        }
        if (type == 'puzzles') {
          if (![
                'match',
                'sort',
                'sequence',
                'spatial',
                'logic',
              ].contains(item['engine']) ||
              item['prompt'] is! String ||
              item['options'] is! List ||
              item['answer'] is! List ||
              (item['answer'] as List).isEmpty ||
              (item['options'] as List).length < 2 ||
              (item['options'] as List).length > 12 ||
              (item['options'] as List).any((v) => v is! String) ||
              (item['answer'] as List).length > 8) {
            throw const FormatException('Invalid puzzle');
          }
          if ((item['answer'] as List).any(
            (v) => !(item['options'] as List).contains(v),
          )) {
            throw const FormatException('Unsolvable puzzle');
          }
        }
        if (type == 'stories') {
          final scenes = item['scenes'];
          if (scenes is! Map ||
              scenes.length > 100 ||
              !scenes.containsKey(item['start'])) {
            throw const FormatException('Invalid story');
          }
          final reachable = <String>{};
          void visit(String id) {
            if (!reachable.add(id)) return;
            final scene = scenes[id];
            if (scene is! Map ||
                scene['text'] is! String ||
                scene['choices'] is! List) {
              throw const FormatException('Invalid scene');
            }
            if(scene['interaction']!=null) {
              final prop=scene['interaction'];
              if(prop is! Map || ['label','symbol','message'].any((k)=>prop[k] is! String || (prop[k] as String).isEmpty)) throw const FormatException('Invalid story interaction');
            }
            if(scene['audio']!=null && (scene['audio'] is! String || !(scene['audio'] as String).startsWith('audio/') || (scene['audio'] as String).contains('..'))) throw const FormatException('Invalid audio path');
            for (final choice in scene['choices']) {
              if (choice['label'] is! String ||
                  !scenes.containsKey(choice['next'])) {
                throw const FormatException('Broken story branch');
              }
              visit(choice['next']);
            }
          }

          visit(item['start']);
          final canEnd = <String>{
            for (final id in reachable)
              if ((scenes[id]['choices'] as List).isEmpty) id,
          };
          var changed = true;
          while (changed) {
            changed = false;
            for (final id in reachable) {
              if (!canEnd.contains(id) &&
                  (scenes[id]['choices'] as List).any(
                    (c) => canEnd.contains(c['next']),
                  )) {
                canEnd.add(id);
                changed = true;
              }
            }
          }
          if (canEnd.length != reachable.length) {
            throw const FormatException('Story cannot finish');
          }
        }
      }
    }
  }
}
