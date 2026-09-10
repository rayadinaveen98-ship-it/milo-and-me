import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../ui/common.dart';
import '../ui/creation_preview.dart';

class MemoriesScreen extends ConsumerWidget {
  const MemoriesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(controllerProvider).world;
    return PageShell(
      title: 'Our book of little wonders',
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: w.memories.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Column(
              children: [
                Text(
                  '${w.petName} & ${w.nickname}',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text('Every adventure has a place here.'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final first in w.companion.firsts.where(
                      (s) =>
                          s.startsWith('theme:') ||
                          [
                            'creativity-five',
                            'puzzle-explorer',
                            'kindness',
                            'science',
                          ].contains(s),
                    ))
                      Chip(
                        avatar: const Icon(Icons.auto_awesome_rounded),
                        label: Text(
                          {
                                'creativity-five': 'Our little art gallery',
                                'puzzle-explorer': 'Five ways to wonder',
                                'kindness': 'A kindness memory',
                                'science': 'Little discoveries',
                              }[first] ??
                              first.replaceFirst('theme:', 'Our '),
                        ),
                      ),
                  ],
                ),
                if (w.memories.isEmpty)
                  const Paper(
                    color: Brand.lavender,
                    child: Text(
                      'Our first page is waiting. Shall we make a picture together?',
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            );
          }
          final m = w.memories[w.memories.length - i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Paper(
              color: m.kind == 'drawing'
                  ? Colors.white
                  : m.kind == 'story'
                  ? Brand.lavender
                  : Brand.sky,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        m.kind == 'drawing'
                            ? Icons.palette_rounded
                            : m.kind == 'science'
                            ? Icons.eco_rounded
                            : m.kind == 'story'
                            ? Icons.auto_stories_rounded
                            : Icons.favorite_rounded,
                        color: Brand.sage,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          m.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  if (m.kind == 'drawing')
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: SizedBox(
                        height: 240,
                        width: double.infinity,
                        child: CreationPreview(key: ValueKey(m.id), memory: m),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    '${m.at.day}.${m.at.month}.${m.at.year} · Made a memory together',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
