import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../ui/common.dart';

class CatalogueScreen extends ConsumerWidget {
  final String kind;
  const CatalogueScreen({super.key, required this.kind});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(controllerProvider);
    final items = app.content.list(kind);
    final title = {
      'drawings': 'The art corner',
      'puzzles': 'Our little puzzle box',
      'stories': 'A story, together',
    }[kind]!;
    final icon = {
      'drawings': Icons.brush_rounded,
      'puzzles': Icons.extension_rounded,
      'stories': Icons.auto_stories_rounded,
    }[kind]!;
    return PageShell(
      title: title,
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text(
            {
              'drawings': 'What shall we make for our home?',
              'puzzles': 'A tiny challenge. A big discovery.',
              'stories': 'You choose where the adventure goes.',
            }[kind]!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 22),
          if (kind == 'drawings')
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: FilledButton.icon(
                onPressed: () => context.go('/drawing/create'),
                icon: const Icon(Icons.palette_rounded),
                label: const Text('My own imagination'),
              ),
            ),
          LayoutBuilder(
            builder: (context, c) => Wrap(
              spacing: 14,
              runSpacing: 14,
              children: items.asMap().entries.map((entry) {
                final item = entry.value;
                final done =
                    app.world.completedPuzzles.contains(item['id']) ||
                    app.world.completedStories.contains(item['id']);
                final resume = app.world.storyPositions.containsKey(item['id']);
                final route = {
                  'drawings': 'drawing',
                  'puzzles': 'puzzle',
                  'stories': 'story',
                }[kind];
                final colors = [
                  Brand.peach,
                  Brand.mint,
                  Brand.sky,
                  Brand.lavender,
                  Brand.gold,
                ];
                return SizedBox(
                  width: c.maxWidth > 650
                      ? (c.maxWidth - 28) / 3
                      : (c.maxWidth - 14) / 2,
                  child: Material(
                    color: colors[entry.key % colors.length],
                    borderRadius: BorderRadius.circular(26),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(26),
                      onTap: () => context.go('/$route/${item['id']}'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 14,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              done ? Icons.check_circle_rounded : icon,
                              size: 42,
                              color: Brand.ink,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              item['title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              resume
                                  ? 'Continue our story'
                                  : done
                                  ? 'Play together again'
                                  : item['subtitle'] ?? 'Let’s discover',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
