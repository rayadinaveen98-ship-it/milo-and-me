import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../domain/models.dart';
import '../domain/scenario_engine.dart';
import '../ui/common.dart';
import '../ui/pet.dart';
import '../ui/illustrated.dart';

class ScenarioCatalogue extends ConsumerWidget {
  final String kind;
  const ScenarioCatalogue({super.key, required this.kind});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(controllerProvider), items = app.content.list(kind);
    return PageShell(
      title: kind == 'cooking' ? 'Our pretend kitchen' : 'Let’s pretend',
      child: ListView.builder(
        padding: const EdgeInsets.all(22),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                kind == 'cooking'
                    ? 'Everything in this kitchen is pretend. Let’s make something with Milo!'
                    : 'A costume, a few props, a world of imagination.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          }
          final item = items[index - 1],
              p = ScenarioEngine().progress(app.world, kind, item['id']);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Material(
              color: kind == 'cooking' ? Brand.peach : Brand.lavender,
              borderRadius: BorderRadius.circular(24),
              child: ListTile(
                minVerticalPadding: 24,
                leading: SizedBox(width: 70, height: 80, child: kind == 'cooking'
                  ? ArtObject({'pancakes': 0, 'sandwich': 1, 'fruit-bowl': 2, 'pizza': 3, 'cake': 4}[item['id']] ?? 4,
                    atlas: 'food', columns: 3, rows: 2)
                  : ArtObject({'astronaut': 2, 'chef': 3, 'doctor': 11, 'beret': 0, 'detective': 5, 'builder': 4}[item['outfit']] ?? 11)),
                title: Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  ScenarioEngine().complete(item, p)
                      ? 'Our memory is ready'
                      : p['index'] > 0
                      ? 'Continue our adventure'
                      : item['subtitle'],
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.go('/$kind/${item['id']}'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ScenarioScreen extends ConsumerStatefulWidget {
  final String kind, id;
  const ScenarioScreen({super.key, required this.kind, required this.id});
  @override
  ConsumerState<ScenarioScreen> createState() => _ScenarioState();
}

class _ScenarioState extends ConsumerState<ScenarioScreen> {
  bool busy = false, timerReady = false;
  int timerStep = -1;
  String? feedback;
  Future<void> perform(Json definition, String choice) async {
    if (busy) return;
    setState(() => busy = true);
    final ok = await ref
        .read(controllerProvider)
        .scenarioAction(widget.kind, definition, choice);
    if (mounted) {
      setState(() {
        busy = false;
        feedback = ok ? null : 'Let’s give our pretend recipe another moment.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(controllerProvider),
        definition = app.content.find(widget.kind, widget.id);
    if (definition == null) {
      return const PageShell(
        title: 'Our adventure',
        child: Center(
          child: Text('This adventure is resting. Try another one.'),
        ),
      );
    }
    final engine = ScenarioEngine(),
        p = engine.progress(app.world, widget.kind, widget.id);
    final done = engine.complete(definition, p), index = p['index'] as int;
    final step = done
        ? null
        : Map<String, dynamic>.from(definition['steps'][index]);
    if (timerStep != index) {
      timerStep = index;
      timerReady = false;
    }
    final reduced =
        app.world.reducedMotion || MediaQuery.disableAnimationsOf(context);
    final timing = step?['action'] == 'timing';
    final options = step == null
        ? <String>[]
        : List<String>.from(step['options']);
    final stored = app.world.memories.any(
      (m) => m.id == '${widget.kind}:${widget.id}',
    );
    return PageShell(
      title: definition['title'],
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text(
            widget.kind == 'cooking'
                ? 'Our kitchen is make-believe'
                : 'Our adventure is pretend play',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Brand.sage),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 360,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: SceneArt(widget.kind == 'cooking' || definition['outfit'] == 'chef' ? 'care'
                      : definition['outfit'] == 'astronaut' ? 'space'
                      : definition['outfit'] == 'beret' ? 'studio'
                      : definition['outfit'] == 'detective' ? 'stories' : 'play', fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  width: 170,
                  height: 230,
                  child: PetView(
                    color: app.world.color,
                    outfit: widget.kind == 'cooking' ? 'chef' : definition['outfit'] ?? app.world.outfit,
                    pose: done ? 'celebrating' : widget.kind == 'cooking' ? 'cooking' : 'curious',
                    reducedMotion: reduced,
                  ),
                ),
                Positioned(
                  left: 24,
                  bottom: 30,
                  right: 100,
                  child: DragTarget<String>(
                    onWillAcceptWithDetails: (d) =>
                        !busy &&
                        options.contains(d.data) &&
                        (!timing || timerReady),
                    onAcceptWithDetails: (d) => perform(definition, d.data),
                    builder: (c, accepted, rejected) => Semantics(
                      label: widget.kind == 'cooking'
                          ? 'Pretend cooking area'
                          : 'Pretend prop area',
                      button: !done,
                      child: GestureDetector(
                        onPanEnd: done || busy || timing
                            ? null
                            : (_) => perform(definition, options.first),
                        onTap: done || busy || (timing && !timerReady)
                            ? null
                            : () => perform(definition, options.first),
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: accepted.isEmpty
                                ? Colors.transparent
                                : Brand.mint,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: AnimatedSwitcher(duration: Duration(milliseconds: reduced ? 0 : 300),
                            child: Transform.rotate(key: ValueKey('$index:${p['count']}'),
                              angle: reduced || step?['action'] != 'mix' ? 0 : (p['count'] as int).isEven ? -.08 : .08,
                              child: widget.kind == 'cooking'
                                ? (done || index >= (definition['steps'] as List).length - 2
                                  ? ArtObject({'pancakes': 0, 'sandwich': 1, 'fruit-bowl': 2, 'pizza': 3, 'cake': 4}[widget.id] ?? 4,
                                    atlas: 'food', columns: 3, rows: 2)
                                  : index == 0 ? const ArtObject(5, atlas: 'food', columns: 3, rows: 2) : const ArtObject(8))
                                : ArtObject({'astronaut': 2, 'chef': 9, 'doctor': 11, 'beret': 0, 'detective': 5, 'builder': 4}[definition['outfit']] ?? 11))),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Paper(
            color: Brand.mint,
            child: Text(
              done ? 'We made a new memory together.' : step!['prompt'],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (!done) ...[
            const SizedBox(height: 12),
            Text(
              'Part ${index + 1} of ${(definition['steps'] as List).length}',
              textAlign: TextAlign.center,
            ),
            if ((step!['repeat'] ?? 1) > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  step['repeat'],
                  (i) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      i < (p['count'] as int)
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: Brand.sage,
                    ),
                  ),
                ),
              ),
            if (timing)
              TweenAnimationBuilder<double>(
                key: ValueKey(index),
                tween: Tween(begin: 0, end: 1),
                duration: Duration(seconds: (step['seconds'] ?? 2) + 1),
                onEnd: () {
                  if (mounted) setState(() => timerReady = true);
                },
                builder: (c, value, child) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: LinearProgressIndicator(
                    value: value,
                    semanticsLabel: 'Our pretend recipe is getting ready',
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final option in options)
                  Draggable<String>(
                    data: option,
                    maxSimultaneousDrags: busy || timing ? 0 : 1,
                    feedback: Material(
                      color: Brand.gold,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Text(
                          option,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    child: FilledButton.tonal(
                      onPressed: busy || (timing && !timerReady)
                          ? null
                          : () => perform(definition, option),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(option),
                      ),
                    ),
                  ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: busy
                  ? null
                  : () async {
                      setState(() => busy = true);
                      final ok = await app.finishScenario(
                        widget.kind,
                        definition,
                      );
                      if (ok) {
                        await app.audio.reward();
                      }
                      if (ok && context.mounted) {
                        await showReward(
                          context,
                          'A memory with Milo',
                          'Our ${definition['topic']} has a place in our world.',
                        );
                      }
                      if (mounted) setState(() => busy = false);
                    },
              icon: const Icon(Icons.favorite_rounded),
              label: Text(stored ? 'Visit our memory' : 'Keep our adventure'),
            ),
            TextButton(
              onPressed: busy
                  ? null
                  : () => app.replayScenario(widget.kind, widget.id),
              child: const Text('Imagine it another way'),
            ),
          ],
          if (feedback != null) Text(feedback!, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class ScenarioPainter extends CustomPainter {
  final bool cooking;
  final String action;
  final int count, index;
  ScenarioPainter({
    required this.cooking,
    required this.action,
    required this.count,
    required this.index,
  });
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..isAntiAlias = true;
    c.drawRect(
      Offset.zero & s,
      p..color = cooking ? Brand.peach : Brand.lavender,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, s.height * .64, s.width, s.height * .36),
        const Radius.circular(14),
      ),
      p..color = Brand.cream,
    );
    if (cooking) {
      c.drawOval(
        Rect.fromLTWH(
          s.width * .12,
          s.height * .55,
          s.width * .5,
          s.height * .3,
        ),
        p..color = Brand.sage,
      );
      c.drawOval(
        Rect.fromLTWH(
          s.width * .14,
          s.height * .5,
          s.width * .46,
          s.height * .14,
        ),
        p..color = index > 2 ? Brand.gold : Colors.white,
      );
      for (var i = 0; i < index + count; i++) {
        c.drawCircle(
          Offset(
            s.width * (.2 + .035 * (i % 8)),
            s.height * (.55 + .02 * math.sin(i)),
          ),
          5,
          p..color = i % 2 == 0 ? Brand.peach : Brand.lavender,
        );
      }
    } else {
      for (var i = 0; i <= index; i++) {
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              s.width * .08 + i * 24,
              s.height * .7 - (i % 2) * 20,
              32,
              35,
            ),
            const Radius.circular(7),
          ),
          p..color = i % 2 == 0 ? Brand.sky : Brand.gold,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ScenarioPainter old) =>
      old.index != index ||
      old.count != count ||
      old.action != action ||
      old.cooking != cooking;
}
