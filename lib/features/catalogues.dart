import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../ui/common.dart';
import 'drawing.dart';

class CatalogueScreen extends ConsumerStatefulWidget {
  final String kind;
  const CatalogueScreen({super.key, required this.kind});
  @override
  ConsumerState<CatalogueScreen> createState() => _CatalogueState();
}

class _CatalogueState extends ConsumerState<CatalogueScreen> {
  String theme = 'All';
  @override
  Widget build(BuildContext context) {
    final app = ref.watch(controllerProvider), kind = widget.kind;
    final all = app.content.list(kind).where((d) => app.access.allows(kind, d)).toList();
    final items = all
        .where((item) => theme == 'All' || item['theme'] == theme)
        .toList();
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
    final route = {
      'drawings': 'drawing',
      'puzzles': 'puzzle',
      'stories': 'story',
    }[kind]!;
    return PageShell(
      title: title,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
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
                  const SizedBox(height: 16),
                  if (kind == 'drawings')
                    FilledButton.icon(
                      onPressed: () => context.go('/drawing/create'),
                      icon: const Icon(Icons.palette_rounded),
                      label: const Text('My own imagination'),
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final value in [
                        'All',
                        ...all
                            .map((item) => item['theme'] as String? ?? 'Nature')
                            .toSet(),
                      ])
                        ChoiceChip(
                          label: Text(value),
                          selected: theme == value,
                          onSelected: (_) => setState(() => theme = value),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            sliver: SliverLayoutBuilder(
              builder: (context, c) => SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: c.crossAxisExtent > 650 ? 3 : 2,
                  mainAxisExtent: 290,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  final done =
                      app.world.completedPuzzles.contains(item['id']) ||
                      app.world.completedStories.contains(item['id']) ||
                      app.world.memories.any(
                        (m) =>
                            m.kind == 'drawing' &&
                            m.payload['lesson'] == item['id'],
                      );
                  final resume = app.world.storyPositions.containsKey(
                    item['id'],
                  );
                  return Material(
                    color: [
                      Brand.peach,
                      Brand.mint,
                      Brand.sky,
                      Brand.lavender,
                      Brand.gold,
                    ][index % 5],
                    borderRadius: BorderRadius.circular(26),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(26),
                      onTap: () => context.go('/$route/${item['id']}'),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            if (kind == 'drawings')
                              SizedBox(
                                height: 90,
                                width: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CustomPaint(
                                    painter: StrokePainter(
                                      strokes: [],
                                      watch: true,
                                      guides: (item['steps'] as List)
                                          .map(
                                            (v) => Map<String, dynamic>.from(v),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                              )
                            else
                              SizedBox(
                                height: 90,
                                child: Icon(
                                  done ? Icons.check_circle_rounded : icon,
                                  size: 48,
                                  color: Brand.ink,
                                ),
                              ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: Center(
                                child: Text(
                                  item['title'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              resume
                                  ? 'Continue our story'
                                  : done
                                  ? 'Play together again'
                                  : item['subtitle'] ?? 'Let’s discover',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: items.length),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
