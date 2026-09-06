import 'dart:convert';

typedef Json = Map<String, dynamic>;

class Memory {
  final String id, kind, title, topic;
  final DateTime at;
  final Json payload;
  const Memory({
    required this.id,
    required this.kind,
    required this.title,
    required this.topic,
    required this.at,
    this.payload = const {},
  });
  Json toJson() => {
    'id': id,
    'kind': kind,
    'title': title,
    'topic': topic,
    'at': at.toIso8601String(),
    'payload': payload,
  };
  factory Memory.fromJson(Json j) => Memory(
    id: j['id'],
    kind: j['kind'],
    title: j['title'],
    topic: j['topic'],
    at: DateTime.parse(j['at']),
    payload: Map<String, dynamic>.from(j['payload'] ?? {}),
  );
}

class CompanionState {
  int curiosity, interactions, cursor;
  String recentActivity, recentTopic, recentReward, stage, careState, area;
  DateTime? lastInteraction, lastSession;
  List<String> recentLines;
  Map<String, int> favourites;
  Map<String, String> displaySlots;
  Set<String> firsts;
  CompanionState({
    this.curiosity = 50,
    this.interactions = 0,
    this.cursor = 0,
    this.recentActivity = '',
    this.recentTopic = '',
    this.recentReward = '',
    this.stage = 'new-friend',
    this.careState = 'comfortable',
    this.area = 'home',
    this.lastInteraction,
    this.lastSession,
    List<String>? recentLines,
    Map<String, int>? favourites,
    Map<String, String>? displaySlots,
    Set<String>? firsts,
  }) : recentLines = recentLines ?? [],
       favourites = favourites ?? {},
       displaySlots = displaySlots ?? {},
       firsts = firsts ?? {};
  Json toJson() => {
    'schema': 1,
    'curiosity': curiosity,
    'interactions': interactions,
    'cursor': cursor,
    'recentActivity': recentActivity,
    'recentTopic': recentTopic,
    'recentReward': recentReward,
    'stage': stage,
    'careState': careState,
    'area': area,
    'lastInteraction': lastInteraction?.toIso8601String(),
    'lastSession': lastSession?.toIso8601String(),
    'recentLines': recentLines,
    'favourites': favourites,
    'displaySlots': displaySlots,
    'firsts': firsts.toList(),
  };
  factory CompanionState.fromJson(Json j) {
    if (j['schema'] != 1) {
      throw const FormatException('Unsupported companion version');
    }
    return CompanionState(
      curiosity: j['curiosity'],
      interactions: j['interactions'],
      cursor: j['cursor'],
      recentActivity: j['recentActivity'],
      recentTopic: j['recentTopic'],
      recentReward: j['recentReward'],
      stage: j['stage'],
      careState: j['careState'],
      area: j['area'],
      lastInteraction: DateTime.tryParse(j['lastInteraction'] ?? ''),
      lastSession: DateTime.tryParse(j['lastSession'] ?? ''),
      recentLines: List<String>.from(j['recentLines']),
      favourites: Map<String, int>.from(j['favourites']),
      displaySlots: Map<String, String>.from(j['displaySlots']),
      firsts: Set<String>.from(j['firsts']),
    );
  }
  void remember(Memory m) {
    recentActivity = m.kind;
    recentTopic = m.topic;
    lastInteraction = m.at;
    favourites.update(m.kind, (n) => n + 1, ifAbsent: () => 1);
    firsts.add(m.kind);
    recentReward = 'first:${m.kind}';
    if (m.kind == 'drawing') displaySlots['picture'] = m.id;
    if (m.kind == 'story' || m.kind == 'puzzle') displaySlots[m.kind] = m.id;
    curiosity = (curiosity + 3).clamp(0, 100).toInt();
    stage = firsts.length >= 3 ? 'adventure-friends' : 'growing-friends';
  }
}

class World {
  String nickname, petName, outfit, mood, dialogue;
  int color, affection, energy, sessionMinutes;
  bool onboarded, reducedMotion, music, effects, voice, privacyAccepted;
  List<Memory> memories;
  CompanionState companion;
  Set<String> owned, completedPuzzles, completedStories;
  Map<String, String> storyPositions;
  Map<String, Json> activities;
  World({
    this.nickname = '',
    this.petName = 'Milo',
    this.outfit = 'none',
    this.mood = 'happy',
    this.dialogue = 'A little adventure together?',
    this.color = 0,
    this.affection = 50,
    this.energy = 80,
    this.sessionMinutes = 20,
    this.onboarded = false,
    this.reducedMotion = false,
    this.music = false,
    this.effects = true,
    this.voice = true,
    this.privacyAccepted = false,
    CompanionState? companion,
    List<Memory>? memories,
    Set<String>? owned,
    Set<String>? completedPuzzles,
    Set<String>? completedStories,
    Map<String, String>? storyPositions,
    Map<String, Json>? activities,
  }) : companion = companion ?? CompanionState(),
       memories = memories ?? [],
       owned = owned ?? {'none', 'scarf'},
       completedPuzzles = completedPuzzles ?? {},
       completedStories = completedStories ?? {},
       storyPositions = storyPositions ?? {},
       activities = activities ?? {};
  Json toJson() => {
    'schema': 2,
    'companion': companion.toJson(),
    'nickname': nickname,
    'petName': petName,
    'outfit': outfit,
    'mood': mood,
    'dialogue': dialogue,
    'color': color,
    'affection': affection,
    'energy': energy,
    'sessionMinutes': sessionMinutes,
    'onboarded': onboarded,
    'reducedMotion': reducedMotion,
    'music': music,
    'effects': effects,
    'voice': voice,
    'privacyAccepted': privacyAccepted,
    'memories': memories.map((m) => m.toJson()).toList(),
    'owned': owned.toList(),
    'completedPuzzles': completedPuzzles.toList(),
    'completedStories': completedStories.toList(),
    'storyPositions': storyPositions,
    'activities': activities,
  };
  factory World.fromJson(Json j) {
    if (j['schema'] != 1 && j['schema'] != 2) {
      throw const FormatException('Unsupported save version');
    }
    final companion = j['schema'] == 2
        ? CompanionState.fromJson(Map<String, dynamic>.from(j['companion']))
        : CompanionState();
    if (j['schema'] == 1) {
      for (final raw in j['memories']) {
        companion.remember(Memory.fromJson(Map<String, dynamic>.from(raw)));
      }
    }
    return World(
      companion: companion,
      nickname: j['nickname'],
      petName: j['petName'],
      outfit: j['outfit'],
      mood: j['mood'],
      dialogue: j['dialogue'],
      color: j['color'],
      affection: j['affection'],
      energy: j['energy'],
      sessionMinutes: j['sessionMinutes'],
      onboarded: j['onboarded'],
      reducedMotion: j['reducedMotion'],
      music: j['music'],
      effects: j['effects'],
      voice: j['voice'],
      privacyAccepted: j['privacyAccepted'],
      memories: (j['memories'] as List)
          .map((m) => Memory.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
      owned: Set<String>.from(j['owned']),
      completedPuzzles: Set<String>.from(j['completedPuzzles']),
      completedStories: Set<String>.from(j['completedStories']),
      storyPositions: Map<String, String>.from(j['storyPositions']),
      activities: (j['activities'] as Map? ?? {}).map(
        (key, value) =>
            MapEntry(key as String, Map<String, dynamic>.from(value)),
      ),
    );
  }
  World copy() => World.fromJson(jsonDecode(jsonEncode(toJson())));
}

class DrawingStroke {
  final int color;
  final double width;
  final bool erase;
  final List<List<double>> points;
  DrawingStroke({
    required this.color,
    required this.width,
    required this.points,
    this.erase = false,
  });
  Json toJson() => {
    'color': color,
    'width': width,
    'erase': erase,
    'points': points,
  };
  factory DrawingStroke.fromJson(Json j) => DrawingStroke(
    color: j['color'],
    width: (j['width'] as num).toDouble(),
    erase: j['erase'] ?? false,
    points: (j['points'] as List)
        .map((p) => (p as List).map((v) => (v as num).toDouble()).toList())
        .toList(),
  );
}
