import 'models.dart';

class ScenarioEngine {
  static const actions = {
    'choose',
    'pour',
    'mix',
    'spread',
    'decorate',
    'assemble',
    'timing',
    'serve',
    'prop',
    'choice',
  };
  static void validate(Json scenario) {
    if (scenario['steps'] is! List ||
        (scenario['steps'] as List).isEmpty ||
        (scenario['steps'] as List).length > 24) {
      throw const FormatException('Invalid scenario steps');
    }
    for (final step in scenario['steps']) {
      if (step is! Map ||
          !actions.contains(step['action']) ||
          step['prompt'] is! String ||
          step['symbol'] is! String ||
          step['options'] is! List ||
          (step['options'] as List).isEmpty ||
          (step['options'] as List).length > 8 ||
          (step['options'] as List).any((o) => o is! String)) {
        throw const FormatException('Invalid scenario action');
      }
      if (step['repeat'] != null &&
          (step['repeat'] is! int ||
              step['repeat'] < 1 ||
              step['repeat'] > 6)) {
        throw const FormatException('Invalid action count');
      }
      if (step['seconds'] != null &&
          (step['seconds'] is! int ||
              step['seconds'] < 1 ||
              step['seconds'] > 5)) {
        throw const FormatException('Invalid pretend timer');
      }
    }
  }

  Json progress(World w, String kind, String id) => Map<String, dynamic>.from(
    w.activities['$kind:$id'] ??
        {'schema': 1, 'index': 0, 'count': 0, 'choices': <String>[]},
  );
  bool complete(Json definition, Json progress) =>
      (progress['index'] as int) >= (definition['steps'] as List).length;
  World perform(
    World current,
    String kind,
    Json definition,
    String choice, {
    DateTime? now,
  }) {
    validate(definition);
    final w = current.copy(), p = progress(w, kind, definition['id']);
    if (complete(definition, p)) return w;
    final step = definition['steps'][p['index']];
    if (!(step['options'] as List).contains(choice)) {
      throw const FormatException('Unknown scenario choice');
    }
    final stamp = now ?? DateTime.now();
    if (step['action'] == 'timing') {
      final entered = DateTime.tryParse(p['enteredAt'] ?? '') ?? stamp;
      if (stamp.difference(entered).inSeconds < (step['seconds'] ?? 2)) {
        throw const FormatException('Our pretend recipe needs another moment');
      }
    }
    final count = (p['count'] as int) + 1;
    if (count >= (step['repeat'] ?? 1)) {
      p['index'] = (p['index'] as int) + 1;
      p['count'] = 0;
      p['enteredAt'] = stamp.toIso8601String();
      p['choices'] = [...List<String>.from(p['choices']), choice];
    } else {
      p['count'] = count;
    }
    w.activities['$kind:${definition['id']}'] = p;
    w.companion.recentActivity = kind;
    w.companion.recentTopic = definition['topic'];
    w.companion.lastInteraction = stamp;
    w.mood = step['action'] == 'serve' ? 'dance' : 'curious';
    return w;
  }
}
