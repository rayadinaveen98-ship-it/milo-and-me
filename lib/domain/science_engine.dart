import 'models.dart';
import 'engines.dart';

/// Only reviewed templates can create real-world instructions. Downloaded prose
/// cannot quietly turn a digital experiment into an adult-assisted activity.
class ScienceEngine {
  static const digital = {
    'colour',
    'shadow',
    'float',
    'plant',
    'magnet',
    'water',
    'pattern',
  };
  static const observations = {'red-objects', 'room-patterns'};
  static const assisted = {'leaf-shapes'};
  static void validate(Json d) {
    final level = d['safety'];
    final template = d['template'];
    if (!((level == 'A' && digital.contains(template)) ||
        (level == 'B' && observations.contains(template)) ||
        (level == 'C' && assisted.contains(template)))) {
      throw const FormatException('Unreviewed science safety template');
    }
    if (d['rounds'] is! List ||
        (d['rounds'] as List).isEmpty ||
        (d['rounds'] as List).length > 8) {
      throw const FormatException('Invalid discovery rounds');
    }
    if (level != 'A' && (d['rounds'] as List).length != 3) {
      throw const FormatException('Observation templates have three steps');
    }
    for (final r in d['rounds']) {
      if (r is! Map ||
          r['prompt'] is! String ||
          r['options'] is! List ||
          (r['options'] as List).length < 2 ||
          (r['options'] as List).length > 5 ||
          (r['options'] as List).any((o) => o is! String) ||
          r['responses'] is! Map ||
          (r['options'] as List).any((o) => r['responses'][o] is! String)) {
        throw const FormatException('Invalid discovery choices');
      }
    }
  }

  static const adultRole =
      'Grown-up: stay beside your child. Choose three large, clean fallen leaves yourself, or draw three leaf outlines on paper. Avoid unknown plants, roads and water. Do not taste anything. Wash hands afterwards. Stay together until this activity ends.';
  static const offlinePrompts = {
    'red-objects': [
      'From where you are sitting, spot something red. No need to move or touch it.',
      'Can you spot another red thing? Staying in your seat is fine.',
      'One more red shape? It is fine if you cannot see one.',
    ],
    'room-patterns': [
      'From your seat, look for a repeating shape on a safe, familiar object.',
      'Look at its shapes or colours. Does something repeat?',
      'Imagine your own pattern. You can draw it on paper later if you like.',
    ],
    'leaf-shapes': [
      'Stay with your grown-up. Look at the three leaves or paper outlines they chose.',
      'Point to a round edge, a long shape, or a point. Looking is enough.',
      'Your grown-up puts the leaves away. Wash hands together if you handled them.',
    ],
  };
  Json progress(World w, String id) => Map<String, dynamic>.from(
    w.activities['science:$id'] ?? {'index': 0, 'observations': <String>[]},
  );
  bool complete(Json d, Json p) => p['index'] >= (d['rounds'] as List).length;
  String prompt(Json d, int i) => d['safety'] == 'A'
      ? d['rounds'][i]['prompt']
      : offlinePrompts[d['template']]![i];
  List<String> options(Json d, int i) => d['safety'] == 'A'
      ? List<String>.from(d['rounds'][i]['options'])
      : ['I noticed it', 'Imagine it instead'];
  String response(Json d, int i, String choice) => d['safety'] == 'A'
      ? d['rounds'][i]['responses'][choice]
      : 'Noticing and imagining are both lovely ways to explore.';
  World observe(
    World current,
    Json d,
    String choice, {
    required bool adultPresent,
  }) {
    validate(d);
    if (d['safety'] == 'C' && !adultPresent) {
      throw StateError('Grown-up gate required');
    }
    final w = current.copy(), p = progress(w, d['id']);
    if (complete(d, p)) return w;
    final i = p['index'] as int;
    if (!options(d, i).contains(choice)) {
      throw const FormatException('Unknown observation');
    }
    p['index'] = i + 1;
    p['observations'] = [...List<String>.from(p['observations']), choice];
    w.activities['science:${d['id']}'] = p;
    w.dialogue = response(d, i, choice);
    w.mood = 'curious';
    if (complete(d, p)) {
      return MemoryEngine().add(
        w,
        Memory(
          id: 'science:${d['id']}',
          kind: 'science',
          title: d['title'],
          topic: d['topic'],
          at: DateTime.now(),
          payload: {'theme': d['theme'], 'safety': d['safety']},
        ),
      );
    }
    return w;
  }
}

/// Scoped, short-lived permission; never persisted as child progress.
class AdultActivityPermit {
  String? _id;
  DateTime? _until;
  final DateTime Function() clock;
  AdultActivityPermit({DateTime Function()? clock})
    : clock = clock ?? DateTime.now;
  Future<bool> authorize(String id, Future<bool> Function() verify) async {
    revoke();
    final requestedAt = _generation;
    if (!await verify() || requestedAt != _generation) return false;
    _id = id;
    _until = clock().add(const Duration(minutes: 15));
    return true;
  }

  int _generation = 0;
  bool allows(String id) =>
      _id == id && _until != null && clock().isBefore(_until!);
  void revoke() {
    _id = null;
    _until = null;
    _generation++;
  }
}
