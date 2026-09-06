import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milo_and_me/core/audio.dart';
import 'package:milo_and_me/core/controller.dart';
import 'package:milo_and_me/data/content_repository.dart';
import 'package:milo_and_me/data/database.dart';
import 'package:milo_and_me/domain/models.dart';

class FailingDatabase extends AppDatabase {
  FailingDatabase() : super(NativeDatabase.memory());
  @override
  Future<void> saveWorld(World world, {String? removeDraft}) async =>
      throw StateError('Disk full');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Concurrent edits serialize without losing the first edit', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final app = AppController(
      db,
      ContentRepository(db),
      World(),
      audioOverride: SilentAudio(),
    );
    final results = await Future.wait([
      app.change((w) {
        w.nickname = 'Acorn';
        return w;
      }),
      app.change((w) {
        w.petName = 'Sprout';
        return w;
      }),
    ]);
    expect(results, [true, true]);
    expect(app.world.nickname, 'Acorn');
    expect(app.world.petName, 'Sprout');
    app.dispose();
  });
  test('Failed persistence never publishes a false success', () async {
    final db = FailingDatabase();
    final app = AppController(
      db,
      ContentRepository(db),
      World(nickname: 'Before'),
      audioOverride: SilentAudio(),
    );
    expect(
      await app.change((w) {
        w.nickname = 'After';
        return w;
      }),
      isFalse,
    );
    expect(app.world.nickname, 'Before');
    expect(app.error, isNotNull);
    app.dispose();
  });
  test('Session reset requires parent gate authorization', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final app = AppController(
      db,
      ContentRepository(db),
      World(sessionMinutes: 10),
      sessionSeconds: 600,
      audioOverride: SilentAudio(),
    );
    expect(app.sessionOver, isTrue);
    await app.newSession();
    expect(app.sessionOver, isTrue);
    app.unlockParent();
    await app.newSession();
    expect(app.sessionOver, isFalse);
    app.dispose();
  });
  test('Parent gate is revoked on backgrounding', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final app = AppController(
      db,
      ContentRepository(db),
      World(),
      audioOverride: SilentAudio(),
    );
    app.unlockParent();
    app.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(app.parentUnlocked, isFalse);
    await app.persistSession();
    app.dispose();
  });
}
