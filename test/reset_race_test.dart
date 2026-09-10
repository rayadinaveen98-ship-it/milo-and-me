import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milo_and_me/core/audio.dart';
import 'package:milo_and_me/core/controller.dart';
import 'package:milo_and_me/data/content_repository.dart';
import 'package:milo_and_me/data/database.dart';
import 'package:milo_and_me/domain/models.dart';

class PausedResetDatabase extends AppDatabase {
  final entered = Completer<void>(), resume = Completer<void>();
  PausedResetDatabase() : super(NativeDatabase.memory());
  @override
  Future<void> reset() async {
    entered.complete();
    await resume.future;
    await super.reset();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'A late world edit cannot recreate data while parent reset is running',
    () async {
      final db = PausedResetDatabase();
      final app = AppController(
        db,
        ContentRepository(db),
        World(nickname: 'Before'),
        audioOverride: SilentAudio(),
      );
      await app.change((w) => w);
      app.unlockParent();
      final reset = app.reset();
      await db.entered.future;
      expect(
        await app.change((w) {
          w.nickname = 'Late edit';
          return w;
        }),
        isFalse,
      );
      db.resume.complete();
      expect(await reset, isTrue);
      expect((await db.readWorld()).nickname, '');
      expect(app.world.nickname, '');
      app.dispose();
    },
  );
}
