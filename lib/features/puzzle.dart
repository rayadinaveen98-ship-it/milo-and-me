import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../domain/engines.dart';
import '../ui/common.dart';
import '../ui/pet.dart';
import '../ui/illustrated.dart';

class PuzzleScreen extends ConsumerStatefulWidget {
  final String id;
  const PuzzleScreen({super.key, required this.id});
  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen> {
  List<String> answer = [];
  String feedback = '';
  bool busy = false;
  void choose(String value, int count, {int? slot}) {
    if (busy) return;
    setState(() {
      feedback = '';
      if (slot != null && slot < answer.length) {
        answer[slot] = value;
      } else if (count == 1) {
        answer = [value];
      } else if (answer.length < count) {
        answer.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(controllerProvider),
        p = app.content.find('puzzles', widget.id);
    if (p == null) {
      return const PageShell(
        title: 'Puzzle box',
        child: Center(
          child: Text('This puzzle is unavailable. Try another from our box.'),
        ),
      );
    }
    final count = (p['answer'] as List).length, engine = p['engine'] as String;
    Widget tile(String text, {bool selected = false}) => Container(
      constraints: const BoxConstraints(
        minWidth: 90,
        minHeight: 72,
        maxWidth: 160,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? Brand.gold : Brand.sky,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, color: Brand.ink),
        ),
      ),
    );
    Widget slot(int index) => DragTarget<String>(
      onWillAcceptWithDetails: (_) => !busy && index <= answer.length,
      onAcceptWithDetails: (d) => choose(d.data, count, slot: index),
      builder: (context, candidates, rejected) => Semantics(
        label: 'Answer place ${index + 1}',
        child: InkWell(
          onTap: index < answer.length && !busy
              ? () => setState(() => answer.removeAt(index))
              : null,
          child: Container(
            constraints: const BoxConstraints(minWidth: 68, minHeight: 72),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: candidates.isNotEmpty ? Brand.mint : Colors.white,
              borderRadius: BorderRadius.circular(engine == 'spatial' ? 8 : 18),
              border: Border.all(color: Brand.sage, width: 2),
            ),
            child: Center(
              child: Text(
                index < answer.length ? answer[index] : '${index + 1}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ),
    );
    return PageShell(
      title: p['title'],
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SizedBox(
            height: 260,
            child: ClipRRect(borderRadius: BorderRadius.circular(28),
              child: Stack(children: [
                Positioned.fill(child: SceneArt(artForTheme(p['theme']), fit: BoxFit.cover)),
                Positioned(right: 8, bottom: 0, width: 170, height: 190, child: PetView(
              color: app.world.color,
              outfit: app.world.outfit,
              pose: feedback.isEmpty ? 'curious' : 'happy',
              reducedMotion: app.world.reducedMotion,
            )),
              ])),
          ),
          Paper(
            color: Brand.mint,
            child: Text(
              p['prompt'],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 16),
          if ((p['display'] as String? ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                p['display'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, letterSpacing: 3),
              ),
            ),
          Text(
            count > 1
                ? 'Drag into place, or tap the pieces in order. Tap a placed piece to remove it.'
                : 'Tap your choice, or drag it into the space.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (engine == 'spatial')
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: count,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 82,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (c, i) => slot(i),
            )
          else
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                count,
                (i) => SizedBox(
                  width: count > 1 ? 100 : 160,
                  height: 90,
                  child: slot(i),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final option in (p['options'] as List).cast<String>())
                Draggable<String>(
                  data: option,
                  maxSimultaneousDrags: busy ? 0 : 1,
                  feedback: Material(
                    color: Colors.transparent,
                    child: tile(option, selected: true),
                  ),
                  child: Semantics(
                    button: true,
                    label: option,
                    child: GestureDetector(
                      onTap: () => choose(option, count),
                      child: tile(
                        option,
                        selected: count == 1 && answer.contains(option),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            feedback,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: busy || answer.length != count
                ? null
                : () async {
                    if (!PuzzleEngine().check(p, answer)) {
                      setState(
                        () => feedback =
                            p['hint'] ?? 'Let’s look again together.',
                      );
                      return;
                    }
                    setState(() => busy = true);
                    final ok = await app.completePuzzle(p);
                    if (ok) {
                      await app.audio.reward();
                    }
                    if (ok && context.mounted) {
                      await showReward(
                        context,
                        'We figured it out!',
                        'Our ${p['topic']} belongs in the memory book.',
                      );
                    }
                    if (mounted) setState(() => busy = false);
                  },
            child: Text(busy ? 'Keeping our memory…' : 'Let’s try it'),
          ),
          TextButton(
            onPressed: busy
                ? null
                : () => setState(() {
                    answer = [];
                    feedback = '';
                  }),
            child: const Text('Try a new arrangement'),
          ),
        ],
      ),
    );
  }
}
