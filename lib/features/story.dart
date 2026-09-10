import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../domain/engines.dart';
import '../ui/pet.dart';
import '../ui/common.dart';
import '../ui/pack_background.dart';

class StoryScreen extends ConsumerStatefulWidget {
  final String id;
  const StoryScreen({super.key, required this.id});
  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  bool busy = false;
  @override
  Widget build(BuildContext context) {
    final app = ref.watch(controllerProvider),
        story = app.content.find('stories', widget.id);
    if (story == null) {
      return const PageShell(
        title: 'Story corner',
        child: Center(
          child: Text('This story is unavailable. Your place is saved.'),
        ),
      );
    }
    final position =
        app.world.storyPositions[widget.id] ?? story['start'] as String;
    final scene = StoryEngine().scene(story, position);
    final choices = scene['choices'] as List;
    final interaction = scene['interaction'] as Map?;
    final interacted =
        app.world.activities['story:${widget.id}:$position']?['done'] == true;
    final backgrounds = {
      'space': Brand.lavender,
      'ocean': Brand.sky,
      'meadow': Brand.mint,
      'sunset': Brand.peach,
    };
    return PageShell(
      title: story['title'],
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (scene['backgroundAsset'] is String) PackBackground(reference: scene['backgroundAsset']),
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: backgrounds[scene['background']] ?? Brand.mint,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 20,
                  left: 24,
                  child: Text(
                    scene['symbol'] ?? '✦',
                    style: const TextStyle(fontSize: 60, color: Brand.ink),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 20,
                  left: 60,
                  top: 20,
                  child: PetView(
                    color: app.world.color,
                    pose: scene['emotion'] ?? 'happy',
                    outfit: app.world.outfit,
                    reducedMotion: app.world.reducedMotion,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            (scene['text'] as String)
                .replaceAll('{pet}', app.world.petName)
                .replaceAll('{child}', app.world.nickname),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const Text(
            'Read together • Your place is saved after each choice',
            style: TextStyle(color: Brand.sage),
          ),
          if (interaction != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: FilledButton.tonalIcon(
                icon: Text(
                  interacted ? '✓' : interaction['symbol'],
                  style: const TextStyle(fontSize: 32),
                ),
                label: Text(
                  interacted ? interaction['message'] : interaction['label'],
                ),
                onPressed: busy || interacted
                    ? null
                    : () async {
                        setState(() => busy = true);
                        await app.storyInteract(widget.id, position);
                        if (mounted) setState(() => busy = false);
                      },
              ),
            ),
          if (scene['audio'] != null)
            TextButton.icon(
              onPressed: () => app.audio.narrate(scene['audio']),
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text('Hear this part'),
            ),
          const SizedBox(height: 20),
          for (var i = 0; i < choices.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FilledButton.tonal(
                onPressed: busy || (interaction != null && !interacted)
                    ? null
                    : () async {
                        setState(() => busy = true);
                        final next = StoryEngine().choose(story, position, i);
                        await app.storyPosition(widget.id, next);
                        if (mounted) setState(() => busy = false);
                      },
                child: Text(choices[i]['label']),
              ),
            ),
          if (choices.isEmpty)
            FilledButton.icon(
              onPressed: busy || (interaction != null && !interacted)
                  ? null
                  : () async {
                      setState(() => busy = true);
                      final ok = await app.completeStory(story);
                      if (ok && context.mounted) {
                        await showReward(
                          context,
                          'A story to remember',
                          'Our ${story['topic']} is safe in the memory book. Try on your space helmet!',
                        );
                      }
                      if (mounted) setState(() => busy = false);
                    },
              icon: const Icon(Icons.favorite_rounded),
              label: const Text('Keep this adventure'),
            ),
        ],
      ),
    );
  }
}
