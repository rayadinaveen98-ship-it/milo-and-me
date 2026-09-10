import 'models.dart';

class WorldEngine {
  static const areas = [
    'bedroom',
    'studio',
    'stories',
    'play',
    'care',
    'garden',
  ];
  World visit(World current, String area) {
    if (!areas.contains(area)) throw ArgumentError.value(area, 'area');
    final w = current.copy();
    w.companion.area = area;
    w.mood = 'walk';
    w.dialogue = {
      'bedroom': 'A cosy place for memories and pretending.',
      'studio': 'Our pictures make this room our own.',
      'stories': 'A whole world can fit inside a story.',
      'play': 'I wonder what we could figure out together.',
      'care': 'A little care, a little kindness.',
      'garden': 'Shall we notice something small and wonderful?',
    }[area]!;
    return w;
  }

  Memory? displayedPicture(World w) {
    final drawings = w.memories.where(
      (m) => m.kind == 'drawing' && (m.payload['strokes'] is List || m.payload['creationId'] is String),
    );
    if (drawings.isEmpty) return null;
    final selected = w.companion.displaySlots['picture'];
    return drawings.firstWhere(
      (m) => m.id == selected,
      orElse: () => drawings.last,
    );
  }

  World rotatePicture(World current) {
    final w = current.copy();
    final drawings = w.memories
        .where((m) => m.kind == 'drawing' && (m.payload['strokes'] is List || m.payload['creationId'] is String))
        .toList();
    if (drawings.isEmpty) return w;
    final index = drawings.indexWhere(
      (m) => m.id == w.companion.displaySlots['picture'],
    );
    w.companion.displaySlots['picture'] =
        drawings[(index + 1) % drawings.length].id;
    return w;
  }

  List<String> decorations(World w) => [
    if (w.companion.firsts.contains('drawing')) 'flower',
    if (w.companion.firsts.contains('puzzle')) 'blocks',
    if (w.companion.firsts.contains('story')) 'star',
    if (w.companion.firsts.contains('creativity-five')) 'garland',
    if (w.companion.firsts.contains('science')) 'leaf',
    if (w.companion.firsts.contains('kindness')) 'heart',
  ].reversed.take(3).toList();
}
