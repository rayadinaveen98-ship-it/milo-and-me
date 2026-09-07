import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import '../data/content_repository.dart';
import '../data/parent_security.dart';
import '../domain/models.dart';
import '../domain/engines.dart';
import '../domain/scenario_engine.dart';
import '../domain/science_engine.dart';
import 'audio.dart';

final controllerProvider = ChangeNotifierProvider<AppController>(
  (ref) => throw UnimplementedError('Override at bootstrap'),
);

class AppController extends ChangeNotifier with WidgetsBindingObserver {
  final AppDatabase db;
  final ContentRepository content;
  final ParentSecurity security = ParentSecurity();
  final AudioService audio;
  final adultActivity = AdultActivityPermit();
  World world;
  String? error;
  bool parentUnlocked = false;
  bool foreground = true;
  bool _disposed = false;
  int elapsedSeconds = 0;
  Timer? _timer;
  Future<void> _writes = Future.value();
  AppController(
    this.db,
    this.content,
    this.world, {
    int sessionSeconds = 0,
    AudioService? audioOverride,
  }) : audio = audioOverride ?? AudioDirector() {
    elapsedSeconds = sessionSeconds;
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (foreground && world.onboarded && !parentUnlocked && !sessionOver) {
        elapsedSeconds++;
        if (elapsedSeconds % 10 == 0) {
          persistSession();
          notifyListeners();
        }
      }
    });
    configureAudio();
  }
  bool get sessionOver => elapsedSeconds >= world.sessionMinutes * 60;
  Future<void> configureAudio() async {
    try {
      await audio.configure(
        musicOn: world.music,
        effectsOn: world.effects,
        voiceOn: world.voice,
      );
    } catch (_) {
      /* Audio failure must not block local play. */
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    if (!foreground) {
      parentUnlocked = false;
      adultActivity.revoke();
      persistSession();
      audio.pause();
    } else {
      configureAudio();
    }
    notifyListeners();
  }

  // Serialize read-modify-write and publish only after the SQLite commit succeeds.
  Future<bool> change(World Function(World) operation, {String? removeDraft}) {
    final done = Completer<bool>();
    _writes = _writes.then((_) async {
      try {
        final next = operation(world.copy());
        await db.saveWorld(next, removeDraft: removeDraft);
        world = next;
        error = null;
        notifyListeners();
        done.complete(true);
      } catch (_) {
        error =
            'We couldn’t save that yet. Please try again; your earlier memories are safe.';
        notifyListeners();
        done.complete(false);
      }
    });
    return done.future;
  }

  Future<bool> authorizeScience(String id, String pin) async {
    final ok = await adultActivity.authorize(id, () => security.verify(pin));
    notifyListeners();
    return ok;
  }
  Future<bool> observeScience(Json d, String choice) => change((w) =>
      ScienceEngine().observe(w, d, choice, adultPresent: adultActivity.allows(d['id'])));
  void endScience() { adultActivity.revoke(); }
  Future<bool> suggest() => change(
    (w) => PetEngine().react(
      w,
      now: DateTime.now(),
      sessionMinutes: elapsedSeconds ~/ 60,
    ),
  );
  Future<bool> care(String action) =>
      change((w) => PetEngine().care(w, action));
  Future<bool> remember(Memory memory, {String? draftId}) async {
    final ok = await change(
      (w) => MemoryEngine().add(w, memory),
      removeDraft: draftId,
    );
    if (ok) {
      try {
        await audio.reward();
      } catch (_) {}
    }
    return ok;
  }

  Future<bool> completePuzzle(Json puzzle) => change((w) {
    w.completedPuzzles.add(puzzle['id']);
    return MemoryEngine().add(
      w,
      Memory(
        id: 'puzzle:${puzzle['id']}',
        kind: 'puzzle',
        title: puzzle['title'],
        topic: puzzle['topic'],
        payload: {'theme': puzzle['theme'], 'engine': puzzle['engine']},
        at: DateTime.now(),
      ),
    );
  });
  Future<bool> scenarioAction(String kind, Json definition, String choice) =>
      change((w) => ScenarioEngine().perform(w, kind, definition, choice));
  Future<bool> finishScenario(String kind, Json definition) => change((w) {
    if (!ScenarioEngine().complete(
      definition,
      ScenarioEngine().progress(w, kind, definition['id']),
    )) {
      throw StateError('Scenario is not finished');
    }
    return MemoryEngine().add(
      w,
      Memory(
        id: '$kind:${definition['id']}',
        kind: kind,
        title: definition['title'],
        topic: definition['topic'],
        at: DateTime.now(),
        payload: {'theme': definition['theme'], 'outfit': definition['outfit']},
      ),
    );
  });
  Future<bool> replayScenario(String kind, String id) => change((w) {
    w.activities.remove('$kind:$id');
    return w;
  });
  Future<bool> storyInteract(String id, String scene) => change((w) {
    w.activities['story:$id:$scene'] = {'done': true};
    return w;
  });
  Future<bool> storyPosition(String id, String scene) => change((w) {
    w.storyPositions[id] = scene;
    return w;
  });
  Future<bool> completeStory(Json story) => change((w) {
    w.completedStories.add(story['id']);
    w.storyPositions.remove(story['id']);
    return MemoryEngine().add(
      w,
      Memory(
        id: 'story:${story['id']}',
        kind: 'story',
        title: story['title'],
        topic: story['topic'],
        payload: {'theme': story['theme'], 'milestone': story['milestone']},
        at: DateTime.now(),
      ),
    );
  });
  void dismissError() {
    error = null;
    notifyListeners();
  }

  void unlockParent() {
    parentUnlocked = true;
    notifyListeners();
  }

  void lockParent() {
    parentUnlocked = false;
    notifyListeners();
  }

  Future<void> persistSession() async {
    try {
      await db.saveSession(elapsedSeconds);
    } catch (_) {
      error = 'Session time could not be saved. Please check device storage.';
      notifyListeners();
    }
  }

  Future<void> newSession() async {
    if (!parentUnlocked) return;
    await db.saveSession(0);
    elapsedSeconds = 0;
    notifyListeners();
  }

  Future<bool> reset() async {
    if (!parentUnlocked) return false;
    await _writes;
    try {
      await db.reset();
      world = World();
      elapsedSeconds = 0;
      error = null;
      await audio.pause();
      notifyListeners();
      return true;
    } catch (_) {
      error = 'Your data could not be deleted. Please try again.';
      notifyListeners();
      return false;
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    audio.dispose();
    unawaited(_writes.whenComplete(db.close));
    super.dispose();
  }
}
