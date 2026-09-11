import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../core/audio.dart';
import '../domain/engines.dart';
import '../ui/pet.dart';
import '../ui/common.dart';
import '../ui/pack_background.dart';
import '../ui/illustrated.dart';

class StoryScreen extends ConsumerStatefulWidget {
  final String id;
  const StoryScreen({super.key, required this.id});
  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  final scroll = ScrollController();
  bool busy = false;
  String? narrated;
  AudioService? audio;
  @override
  void dispose() {
    scroll.dispose();
    audio?.stopNarration();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(controllerProvider),
        story = app.content.find('stories', widget.id);
    audio = app.audio;
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
    final scene = StoryEngine().scene(story, position),
        choices = scene['choices'] as List;
    final interaction = scene['interaction'] as Map?;
    final interacted =
        app.world.activities['story:${widget.id}:$position']?['done'] == true;
    final reduced =
        app.world.reducedMotion || MediaQuery.disableAnimationsOf(context);
    final background = scene['background'] == 'moonlight'
        ? 'moonlight'
        : scene['background'] == 'space'
        ? 'space'
        : scene['background'] == 'ocean'
        ? 'ocean'
        : artForTheme(story['theme']);
    if (narrated != position) {
      narrated = position;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await app.audio.stopNarration();
        if (mounted && narrated == position && scene['audio'] is String) {
          await app.audio.narrate(scene['audio']);
        }
      });
    }
    Future<void> touch() async {
      if (busy || interacted) return;
      setState(() => busy = true);
      final ok = await app.storyInteract(widget.id, position);
      if (ok) await app.audio.reward();
      if (mounted) setState(() => busy = false);
    }

    return PageShell(
      title: story['title'],
      child: ListView(
        controller: scroll,
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SizedBox(
            height: (MediaQuery.sizeOf(context).height * .60).clamp(350, 660),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: reduced ? 0 : 400),
              child: LayoutBuilder(
                key: ValueKey(position),
                builder: (context, box) => Stack(
                  children: [
                    Positioned.fill(
                      child: SceneArt(background, fit: BoxFit.cover),
                    ),
                    if (scene['backgroundAsset'] is String)
                      Positioned.fill(
                        child: PackBackground(
                          reference: scene['backgroundAsset'],
                        ),
                      ),
                    Positioned(
                      left: box.maxWidth * .08,
                      bottom: 15,
                      width: box.maxWidth * .60,
                      height: box.maxHeight * .49,
                      child: PetView(
                        color: app.world.color,
                        outfit: app.world.outfit,
                        pose: interacted
                            ? 'proud'
                            : scene['emotion'] ?? 'curious',
                        reducedMotion: reduced,
                      ),
                    ),
                    if (interaction != null)
                      Positioned(
                        left:
                            (box.maxWidth *
                                        ((interaction['x'] as num?)
                                                ?.toDouble() ??
                                            .73) -
                                    48)
                                .clamp(0, box.maxWidth - 96),
                        top:
                            (box.maxHeight *
                                        ((interaction['y'] as num?)
                                                ?.toDouble() ??
                                            .35) -
                                    48)
                                .clamp(0, box.maxHeight - 110),
                        width: 96,
                        height: 110,
                        child: Semantics(
                          label: interaction['label'],
                          button: true,
                          child: GestureDetector(
                            onPanEnd: (_) => touch(),
                            onTap: touch,
                            child: AnimatedContainer(
                              duration: Duration(
                                milliseconds: reduced ? 0 : 280,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Brand.gold.withValues(
                                  alpha: interacted ? .45 : .16,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Brand.gold.withValues(
                                      alpha: interacted ? .6 : .25,
                                    ),
                                    blurRadius: 32,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  interacted
                                      ? Icons.check_rounded
                                      : Icons.touch_app_rounded,
                                  color: Brand.cream,
                                  size: 46,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 14,
                      left: 18,
                      right: 18,
                      child: SpeechLeaf(
                        text: interaction == null
                            ? 'Look, listen, and choose together'
                            : interacted
                            ? interaction['message']
                            : interaction['label'],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
            child: Text(
              (scene['text'] as String)
                  .replaceAll('{pet}', app.world.petName)
                  .replaceAll('{child}', app.world.nickname),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (scene['audio'] is String)
            Center(
              child: IconButton.filledTonal(
                tooltip: 'Hear this part',
                onPressed: () => app.audio.narrate(scene['audio']),
                icon: const Icon(Icons.volume_up_rounded),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 14,
              children: [
                for (var i = 0; i < choices.length; i++)
                  SizedBox(
                    width: 145,
                    child: Opacity(
                      opacity: interaction != null && !interacted ? .55 : 1,
                      child: Material(
                        color: Brand.cream,
                        elevation: 3,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: busy || (interaction != null && !interacted)
                              ? null
                              : () async {
                                  setState(() => busy = true);
                                  final ok = await app.storyPosition(
                                    widget.id,
                                    StoryEngine().choose(story, position, i),
                                  );
                                  if (mounted) {
                                    setState(() => busy = false);
                                    if (ok && scroll.hasClients) {
                                      if (reduced) {
                                        scroll.jumpTo(0);
                                      } else {
                                        await scroll.animateTo(
                                          0,
                                          duration: const Duration(
                                            milliseconds: 350,
                                          ),
                                          curve: Curves.easeOutCubic,
                                        );
                                      }
                                    }
                                  }
                                },
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: SizedBox(
                                  height: 95,
                                  child: SceneArt(
                                    choices[i]['picture'] == 'moonlight'
                                        ? 'moonlight'
                                        : choices[i]['picture'] == 'garden'
                                        ? 'garden'
                                        : i.isEven
                                        ? background
                                        : 'stories',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  choices[i]['label'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (choices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FilledButton.icon(
                onPressed: busy || (interaction != null && !interacted)
                    ? null
                    : () async {
                        setState(() => busy = true);
                        final ok = await app.completeStory(story);
                        if (ok && context.mounted) {
                          await showReward(
                            context,
                            'A story to remember',
                            widget.id == 'missing-moonlight'
                                ? 'Our moonlight keepsake is safe in the memory book.'
                                : 'Our adventure is safe in the memory book.',
                          );
                        }
                        if (mounted) setState(() => busy = false);
                      },
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Keep this adventure'),
              ),
            ),
        ],
      ),
    );
  }
}
