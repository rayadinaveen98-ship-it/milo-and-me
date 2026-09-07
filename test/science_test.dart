import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milo_and_me/domain/models.dart';
import 'package:milo_and_me/domain/science_engine.dart';
import 'package:milo_and_me/domain/engines.dart';
import 'package:milo_and_me/data/database.dart';
import 'package:milo_and_me/data/content_repository.dart';
import 'package:milo_and_me/core/controller.dart';
import 'package:milo_and_me/core/audio.dart';
import 'package:milo_and_me/features/science.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final pack = Map<String, dynamic>.from(
    jsonDecode(File('assets/content/meadow.json').readAsStringSync()),
  );
  final items = (pack['science'] as List)
      .map((d) => Map<String, dynamic>.from(d))
      .toList();
  final engine = ScienceEngine();
  test(
    'Seven digital themes and three offline activities all finish with local memories',
    () {
      ContentEngine.validate(pack);
      expect(
        items
            .where((d) => d['safety'] == 'A')
            .map((d) => d['template'])
            .toSet(),
        ScienceEngine.digital,
      );
      var w = World();
      for (final d in items) {
        for (var i = 0; i < (d['rounds'] as List).length; i++) {
          w = engine.observe(
            w,
            d,
            engine.options(d, i).first,
            adultPresent: true,
          );
        }
      }
      expect(w.memories.where((m) => m.kind == 'science').length, 10);
      expect(w.owned, contains('explorer'));
      expect(MemoryEngine().add(w, w.memories.last).memories.length, 10);
    },
  );
  test('Safety classification cannot be downgraded or invented', () {
    final d = Map<String, dynamic>.from(items.last);
    expect(
      () => engine.observe(World(), d, 'I noticed it', adultPresent: false),
      throwsStateError,
    );
    d['safety'] = 'B';
    expect(() => ScienceEngine.validate(d), throwsFormatException);
    d['safety'] = 'A';
    d['template'] = 'chemicals';
    expect(() => ScienceEngine.validate(d), throwsFormatException);
  });
  test(
    'Adult permission is scoped, expires, and revocation beats pending verification',
    () async {
      var now = DateTime(2026);
      final permit = AdultActivityPermit(clock: () => now);
      expect(await permit.authorize('leaves', () async => false), isFalse);
      expect(await permit.authorize('leaves', () async => true), isTrue);
      expect(permit.allows('other'), isFalse);
      now = now.add(const Duration(minutes: 16));
      expect(permit.allows('leaves'), isFalse);
      expect(
        await permit.authorize('leaves', () async {
          permit.revoke();
          return true;
        }),
        isFalse,
      );
    },
  );
  test('Offline discovery progress survives actual SQLite reopen', () async {
    final dir = await Directory.systemTemp.createTemp('milo-science');
    final file = File('${dir.path}/science.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    final d = items.first;
    await db.saveWorld(
      engine.observe(
        World(),
        d,
        engine.options(d, 0).first,
        adultPresent: false,
      ),
    );
    await db.close();
    db = AppDatabase(NativeDatabase(file));
    expect(engine.progress(await db.readWorld(), d['id'])['index'], 1);
    await db.close();
    await dir.delete(recursive: true);
  });
  test(
    'Backgrounding revokes science permission independently of parent zone',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      final app = AppController(
        db,
        ContentRepository(db),
        World(),
        audioOverride: SilentAudio(),
      );
      await app.adultActivity.authorize('leaf-noticing', () async => true);
      expect(app.parentUnlocked, isFalse);
      app.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(app.adultActivity.allows('leaf-noticing'), isFalse);
      await app.persistSession();
      app.dispose();
    },
  );
  testWidgets(
    'Adult-assisted route shows the PIN gate before instructions can advance',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final content = ContentRepository(db);
      await tester.runAsync(content.load);
      final app = AppController(
        db,
        content,
        World(onboarded: true),
        audioOverride: SilentAudio(),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [controllerProvider.overrideWith((ref) => app)],
          child: const MaterialApp(home: ScienceScreen(id: 'leaf-noticing')),
        ),
      );
      expect(find.text('Parent PIN'), findsOneWidget);
      expect(find.text('Keep our discovery'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
