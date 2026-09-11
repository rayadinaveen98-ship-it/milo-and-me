import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../ui/common.dart';
import 'drawing.dart';
import '../ui/illustrated.dart';

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
    final all = app.content
        .list(kind)
        .where((d) => app.access.allows(kind, d))
        .toList();
    final items = all
        .where((item) => theme == 'All' || item['theme'] == theme)
        .toList();
    final title = {
      'drawings': 'The art corner',
      'puzzles': 'Our little puzzle box',
      'stories': 'A story, together',
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
                  final art = item['id'] == 'missing-moonlight'
                      ? 'moonlight'
                      : artForTheme(item['theme']);
                  return Material(
                    elevation: 3,
                    shadowColor: const Color(0x44344a46),
                    color: Brand.cream,
                    borderRadius: BorderRadius.circular(24),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.go('/$route/${item['id']}'),
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: SceneArt(art, fit: BoxFit.cover),
                                ),
                                if (kind == 'drawings')
                                  Positioned.fill(
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Transform.rotate(
                                        angle: index.isEven ? -.04 : .04,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          color: Brand.cream,
                                          child: CustomPaint(
                                            painter: StrokePainter(
                                              strokes: [],
                                              watch: true,
                                              guides: (item['steps'] as List)
                                                  .map(
                                                    (v) =>
                                                        Map<
                                                          String,
                                                          dynamic
                                                        >.from(v),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (kind == 'puzzles' &&
                                    (item['display'] as String? ?? '')
                                        .isNotEmpty)
                                  Positioned(
                                    left: 10,
                                    right: 10,
                                    bottom: 12,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Brand.cream.withValues(
                                          alpha: .94,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        item['display'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 23,
                                          color: Brand.ink,
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Brand.cream,
                                    child: Icon(
                                      done
                                          ? Icons.check_rounded
                                          : resume
                                          ? Icons.bookmark_rounded
                                          : Icons.play_arrow_rounded,
                                      size: 21,
                                      color: Brand.ink,
                                    ),
                                  ),
                                ),
                                if (kind == 'stories')
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    width: 9,
                                    child: ColoredBox(
                                      color: Brand.ink.withValues(alpha: .55),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 12, 10, 4),
                            child: Text(
                              item['title'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              resume
                                  ? 'Continue'
                                  : done
                                  ? 'Again, together'
                                  : kind == 'stories'
                                  ? 'Open our adventure'
                                  : 'Let’s play',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Brand.sage,
                              ),
                            ),
                          ),
                        ],
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
