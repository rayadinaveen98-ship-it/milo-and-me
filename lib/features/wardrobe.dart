import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../domain/models.dart';
import '../domain/engines.dart';
import '../ui/common.dart';
import '../ui/pet.dart';
import '../ui/illustrated.dart';

class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(controllerProvider), w = app.world;
    const items = {
      'chef': ['Chef hat', 'Make a pretend recipe'],
      'doctor': ['Toy-care badge', 'Finish our cosy toy story'],
      'detective': ['Detective cap', 'Solve the moon-button mystery'],
      'builder': ['Builder helmet', 'Build our pretend bridge'],
      'none': ['Just me', 'Always yours'],
      'scarf': ['Cosy scarf', 'Always yours'],
      'beret': ['Artist beret', 'Make a picture together'],
      'explorer': ['Explorer hat', 'Solve a puzzle together'],
      'astronaut': ['Space helmet', 'Finish a story together'],
    };
    const atlas = {
      'beret': 0,
      'explorer': 1,
      'astronaut': 2,
      'chef': 3,
      'builder': 4,
      'detective': 5,
      'doctor': 6,
      'scarf': 7,
    };
    final visible = items.entries
        .where(
          (e) =>
              app.access.premium ||
              [
                'none',
                'scarf',
                'beret',
                'explorer',
                'astronaut',
              ].contains(e.key),
        )
        .toList();
    return PageShell(
      title: 'A little dress-up',
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                const Positioned.fill(
                  child: SceneArt('bedroom', fit: BoxFit.cover),
                ),
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: w.reducedMotion ? 0 : 250),
                    child: PetView(
                      key: ValueKey(w.outfit),
                      color: w.color,
                      outfit: w.outfit,
                      pose: 'proud',
                      reducedMotion:
                          w.reducedMotion ||
                          MediaQuery.disableAnimationsOf(context),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < Brand.petColors.length; i++)
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: IconButton.filled(
                            tooltip: ['Honey', 'Sage', 'Lilac'][i],
                            style: IconButton.styleFrom(
                              backgroundColor: Brand.petColors[i],
                              foregroundColor: Brand.ink,
                            ),
                            onPressed: () => app.change((next) {
                              next.color = i;
                              return next;
                            }),
                            icon: Icon(
                              w.color == i
                                  ? Icons.check_rounded
                                  : Icons.circle_outlined,
                            ),
                          ),
                        ),
                      if (app.access.premium)
                        IconButton.filledTonal(
                          tooltip: 'Imagine an adventure',
                          onPressed: () => context.go('/roleplay'),
                          icon: const Icon(Icons.theater_comedy_rounded),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 255,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 140,
                mainAxisExtent: 145,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: visible.length,
              itemBuilder: (context, index) {
                final e = visible[index], owned = w.owned.contains(e.key);
                return Tooltip(
                  message: owned ? e.value.first : e.value.last,
                  child: Semantics(
                    label: e.value.first,
                    selected: w.outfit == e.key,
                    button: true,
                    enabled: owned,
                    child: Material(
                      color: w.outfit == e.key ? Brand.gold : Brand.cream,
                      borderRadius: BorderRadius.circular(22),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: !owned
                            ? null
                            : () => app.change((next) {
                                next.outfit = e.key;
                                next.dialogue = 'This feels like me!';
                                if (e.key == 'none') return next;
                                return MemoryEngine().add(
                                  next,
                                  Memory(
                                    id: 'outfit:${e.key}',
                                    kind: 'outfit',
                                    title: 'Our ${e.value.first.toLowerCase()}',
                                    topic: e.value.first.toLowerCase(),
                                    at: DateTime.now(),
                                  ),
                                );
                              }),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: e.key == 'none'
                                          ? Image.asset(
                                              'assets/art/milo.webp',
                                              cacheWidth: 128,
                                            )
                                          : ArtObject(atlas[e.key]!),
                                    ),
                                    if (!owned)
                                      const Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Icon(
                                          Icons.lock_rounded,
                                          color: Brand.ink,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                e.value.first,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
