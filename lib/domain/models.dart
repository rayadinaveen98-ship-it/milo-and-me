import 'dart:convert';

typedef Json = Map<String, dynamic>;
class Memory {
  final String id, kind, title, topic;
  final DateTime at;
  final Json payload;
  const Memory({required this.id, required this.kind, required this.title,
    required this.topic, required this.at, this.payload = const {}});
  Json toJson() => {'id': id, 'kind': kind, 'title': title, 'topic': topic,
    'at': at.toIso8601String(), 'payload': payload};
  factory Memory.fromJson(Json j) => Memory(id: j['id'], kind: j['kind'],
    title: j['title'], topic: j['topic'], at: DateTime.parse(j['at']),
    payload: Map<String, dynamic>.from(j['payload'] ?? {}));
}
class World {
  String nickname, petName, outfit, mood, dialogue;
  int color, affection, energy, sessionMinutes;
  bool onboarded, reducedMotion, music, effects, voice, privacyAccepted;
  List<Memory> memories;
  Set<String> owned, completedPuzzles, completedStories;
  Map<String, String> storyPositions;
  World({this.nickname = '', this.petName = 'Milo', this.outfit = 'none',
    this.mood = 'happy', this.dialogue = 'A little adventure together?', this.color = 0,
    this.affection = 50, this.energy = 80, this.sessionMinutes = 20,
    this.onboarded = false, this.reducedMotion = false, this.music = false,
    this.effects = true, this.voice = true, this.privacyAccepted = false,
    List<Memory>? memories, Set<String>? owned, Set<String>? completedPuzzles,
    Set<String>? completedStories, Map<String, String>? storyPositions}) :
    memories = memories ?? [], owned = owned ?? {'none', 'scarf'},
    completedPuzzles = completedPuzzles ?? {}, completedStories = completedStories ?? {},
    storyPositions = storyPositions ?? {};
  Json toJson() => {'schema': 1, 'nickname': nickname, 'petName': petName,
    'outfit': outfit, 'mood': mood, 'dialogue': dialogue, 'color': color,
    'affection': affection, 'energy': energy, 'sessionMinutes': sessionMinutes,
    'onboarded': onboarded, 'reducedMotion': reducedMotion, 'music': music,
    'effects': effects, 'voice': voice, 'privacyAccepted': privacyAccepted,
    'memories': memories.map((m) => m.toJson()).toList(), 'owned': owned.toList(),
    'completedPuzzles': completedPuzzles.toList(), 'completedStories': completedStories.toList(),
    'storyPositions': storyPositions};
  factory World.fromJson(Json j) {
    if (j['schema'] != 1) { throw const FormatException('Unsupported save version'); }
    return World(nickname: j['nickname'], petName: j['petName'], outfit: j['outfit'],
      mood: j['mood'], dialogue: j['dialogue'], color: j['color'], affection: j['affection'],
      energy: j['energy'], sessionMinutes: j['sessionMinutes'], onboarded: j['onboarded'],
      reducedMotion: j['reducedMotion'], music: j['music'], effects: j['effects'], voice: j['voice'],
      privacyAccepted: j['privacyAccepted'],
      memories: (j['memories'] as List).map((m) => Memory.fromJson(Map<String,dynamic>.from(m))).toList(),
      owned: Set<String>.from(j['owned']), completedPuzzles: Set<String>.from(j['completedPuzzles']),
      completedStories: Set<String>.from(j['completedStories']),
      storyPositions: Map<String,String>.from(j['storyPositions']));
  }
  World copy() => World.fromJson(jsonDecode(jsonEncode(toJson())));
}
class DrawingStroke {
  final int color;
  final double width;
  final bool erase;
  final List<List<double>> points;
  DrawingStroke({required this.color, required this.width, required this.points, this.erase = false});
  Json toJson() => {'color': color, 'width': width, 'erase': erase, 'points': points};
  factory DrawingStroke.fromJson(Json j) => DrawingStroke(color: j['color'],
    width: (j['width'] as num).toDouble(), erase: j['erase'] ?? false,
    points: (j['points'] as List).map((p) => (p as List).map((v) => (v as num).toDouble()).toList()).toList());
}
