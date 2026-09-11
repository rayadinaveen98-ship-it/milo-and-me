import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../domain/world_engine.dart';
import '../ui/pet.dart';
import '../ui/creation_preview.dart';
import '../ui/illustrated.dart';

class WorldScreen extends ConsumerWidget {
  const WorldScreen({super.key});
  static const names = {
    'bedroom': 'Bedroom',
    'studio': 'Art studio',
    'stories': 'Story nook',
    'play': 'Play corner',
    'care': 'Care corner',
    'garden': 'Garden',
  };
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(controllerProvider), w = app.world;
    final engine = WorldEngine();
    final area = names.containsKey(w.companion.area)
        ? w.companion.area
        : 'bedroom';
    final picture = engine.displayedPicture(w);
    final keepsakes = engine.decorations(w);
    final reduced = w.reducedMotion || MediaQuery.disableAnimationsOf(context);
    void route(String path) => context.go(path);
    final left = switch (area) {
      'bedroom' => ('Dress up', '/wardrobe'),
      'studio' => ('Make art', '/drawings'),
      'stories' => ('Open a story', '/stories'),
      'play' => ('Puzzle box', '/puzzles'),
      'care' => ('Our pretend kitchen', '/cooking'),
      _ => ('A flower picture', '/drawing/flower'),
    };
    final right = switch (area) {
      'bedroom' => (w.mood == 'sleep' ? 'Wake up' : 'Rest', ''),
      'studio' => ('Our gallery', '/memories'),
      'stories' => ('Story memories', '/memories'),
      'play' => ('Let’s pretend', '/roleplay'),
      'care' => ('Bubbles', ''),
      _ => ('Discover with Milo', '/science'),
    };
    return Scaffold(
      backgroundColor: const Color(0xff243b38),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.eco_rounded, color: Brand.gold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${w.petName} & ${w.nickname}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Brand.cream,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Memories',
                    onPressed: () => route('/memories'),
                    icon: const Icon(
                      Icons.photo_album_rounded,
                      color: Brand.gold,
                    ),
                  ),
                  IconButton(
                    tooltip: 'For grown-ups',
                    onPressed: () => route('/parent'),
                    icon: const Icon(
                      Icons.lock_outline_rounded,
                      color: Brand.cream,
                    ),
                  ),
                ],
              ),
            ),
            if (app.error != null)
              MaterialBanner(
                content: Text(app.error!),
                actions: [
                  TextButton(
                    onPressed: app.dismissError,
                    child: const Text('Okay'),
                  ),
                ],
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, bounds) => Stack(
                  fit: StackFit.expand,
                  children: [
                  if (bounds.maxWidth > bounds.maxHeight * .85)
                    SceneArt(area, fit: BoxFit.cover),
                  if (bounds.maxWidth > bounds.maxHeight * .85)
                    const ColoredBox(color: Color(0x99243b38)),
                  Center(
                  child: SizedBox(
                    width: bounds.maxWidth.clamp(0, bounds.maxHeight * .85),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: reduced ? 0 : 450),
                            child: SceneArt(area, key: ValueKey(area)),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          top: 12,
                          child: SpeechLeaf(text: w.dialogue),
                        ),
                        if (keepsakes.isNotEmpty)
                          Positioned(
                            right: 16, top: bounds.maxHeight * .20,
                            child: Tooltip(
                              message: 'Our earned keepsakes',
                              child: InkWell(
                                onTap: () => route('/memories'),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(color: Brand.cream.withValues(alpha: .88), borderRadius: BorderRadius.circular(12)),
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    for (final keepsake in keepsakes)
                                      SymbolArt(switch (keepsake) {'blocks' => 'star', 'garland' => 'flower', 'heart' => 'flower', _ => keepsake}, size: 32),
                                    if (w.completedStories.contains('missing-moonlight')) const SymbolArt('moon', size: 32),
                                  ]),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: bounds.maxHeight * .12,
                          height: bounds.maxHeight * .40,
                          child: PetView(
                            color: w.color,
                            outfit: w.outfit,
                            pose: w.mood,
                            reducedMotion: reduced,
                            onTap: () => app.care('cuddle'),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          top: bounds.maxHeight * .30,
                          width: 104,
                          height: bounds.maxHeight * .24,
                          child: WorldHotspot(
                            label: left.$1,
                            onTap: () => route(left.$2),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: bounds.maxHeight * .36,
                          width: 104,
                          height: bounds.maxHeight * .24,
                          child: WorldHotspot(
                            label: right.$1,
                            onTap: () {
                              if (right.$2.isNotEmpty) {
                                route(right.$2);
                              } else {
                                app.care(
                                  area == 'care'
                                      ? 'wash'
                                      : w.mood == 'sleep'
                                      ? 'cuddle'
                                      : 'sleep',
                                );
                              }
                            },
                          ),
                        ),
                        if (picture != null &&
                            (area == 'studio' || area == 'bedroom'))
                          Positioned(
                            left: 130,
                            top: bounds.maxHeight * .22,
                            width: 64,
                            height: 72,
                            child: Tooltip(
                              message: 'Change displayed picture',
                              child: InkWell(
                                onTap: () => app.change(engine.rotatePicture),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  color: Brand.gold,
                                  child: CreationPreview(memory: picture),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 10,
                          child: Center(
                            child: area == 'care'
                                ? FilledButton.tonalIcon(
                                    onPressed: () => app.care('food'),
                                    icon: const Icon(Icons.apple_rounded),
                                    label: const Text('Picnic'),
                                  )
                                : area == 'bedroom'
                                ? FilledButton.tonalIcon(
                                    onPressed: () => route('/roleplay'),
                                    icon: const Icon(
                                      Icons.theater_comedy_rounded,
                                    ),
                                    label: const Text('Let’s pretend'),
                                  )
                                : Text(
                                    names[area]!,
                                    style: const TextStyle(
                                      color: Brand.cream,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 8,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 5,
                runSpacing: 5,
                children: [
                  for (final room in WorldEngine.areas)
                    Tooltip(
                      message: names[room]!,
                      child: Semantics(
                        label: names[room],
                        button: true,
                        selected: area == room,
                        child: InkWell(
                          onTap: () =>
                              app.change((next) => engine.visit(next, room)),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            width: 50,
                            height: 58,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: area == room
                                    ? Brand.gold
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SceneArt(room),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
