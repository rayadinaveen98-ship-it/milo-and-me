import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../domain/models.dart';
import '../domain/world_engine.dart';
import '../ui/common.dart';
import '../ui/pet.dart';
import 'drawing.dart';
import 'home.dart';

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
  static const icons = {
    'bedroom': Icons.bed_rounded,
    'studio': Icons.palette_rounded,
    'stories': Icons.auto_stories_rounded,
    'play': Icons.extension_rounded,
    'care': Icons.bubble_chart_rounded,
    'garden': Icons.yard_rounded,
  };
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(controllerProvider), w = app.world;
    final engine = WorldEngine();
    final area = WorldEngine.areas.contains(w.companion.area)
        ? w.companion.area
        : 'bedroom';
    final picture = engine.displayedPicture(w);
    final night = DateTime.now().hour >= 19 || DateTime.now().hour < 6;
    final reduced = w.reducedMotion || MediaQuery.disableAnimationsOf(context);
    void route(String path) => context.go(path);
    Widget prop(IconData icon, String label, VoidCallback onTap, Color color) =>
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.filledTonal(
              tooltip: label,
              onPressed: onTap,
              style: IconButton.styleFrom(
                minimumSize: const Size(68, 68),
                backgroundColor: color,
                foregroundColor: Brand.ink,
              ),
              icon: Icon(icon, size: 36),
            ),
            SizedBox(
              width: 100,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
    final left = switch (area) {
      'bedroom' => prop(
        Icons.checkroom_rounded,
        'Dress up',
        () => route('/wardrobe'),
        Brand.sky,
      ),
      'studio' => prop(
        Icons.brush_rounded,
        'Make art',
        () => route('/drawings'),
        Brand.peach,
      ),
      'stories' => prop(
        Icons.menu_book_rounded,
        'Open a story',
        () => route('/stories'),
        Brand.lavender,
      ),
      'play' => prop(
        Icons.extension_rounded,
        'Puzzle box',
        () => route('/puzzles'),
        Brand.gold,
      ),
      'care' => prop(
        Icons.apple_rounded,
        'Picnic',
        () => app.care('food'),
        Brand.peach,
      ),
      _ => prop(
        Icons.local_florist_rounded,
        'A flower picture',
        () => route('/drawing/flower'),
        Brand.peach,
      ),
    };
    final right = switch (area) {
      'bedroom' => prop(
        Icons.bedtime_rounded,
        w.mood == 'sleep' ? 'Wake up' : 'Rest',
        () => app.care(w.mood == 'sleep' ? 'cuddle' : 'sleep'),
        Brand.lavender,
      ),
      'studio' => prop(
        Icons.photo_library_rounded,
        'Our gallery',
        () => route('/memories'),
        Brand.gold,
      ),
      'stories' => prop(
        Icons.star_rounded,
        'Story memories',
        () => route('/memories'),
        Brand.gold,
      ),
      'play' => prop(
        Icons.toys_rounded,
        'Our keepsakes',
        () => route('/memories'),
        Brand.sky,
      ),
      'care' => prop(
        Icons.bubble_chart_rounded,
        'Bubbles',
        () => app.care('wash'),
        Brand.sky,
      ),
      _ => prop(
        Icons.park_rounded,
        'Draw a tree',
        () => route('/drawing/tree'),
        Brand.mint,
      ),
    };
    return PageShell(
      title: 'Our little world',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Paper(
            color: Brand.mint,
            padding: const EdgeInsets.all(14),
            child: Text(
              w.dialogue,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            names[area]!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) => AspectRatio(
              aspectRatio: c.maxWidth > 650 ? 1.7 : .95,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: reduced ? 0 : 280),
                child: ClipRRect(
                  key: ValueKey(area),
                  borderRadius: BorderRadius.circular(30),
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final width = box.maxWidth, height = box.maxHeight;
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: area == 'garden'
                                  ? GardenPainter(night: night)
                                  : RoomPainter(night: night),
                            ),
                          ),
                          Positioned(
                            left: width * .2,
                            top: height * .28,
                            width: width * .6,
                            height: height * .48,
                            child: PetView(
                              color: w.color,
                              pose: w.mood,
                              outfit: w.outfit,
                              reducedMotion: reduced,
                              onTap: () => app.care('cuddle'),
                            ),
                          ),
                          Positioned(left: 8, bottom: 16, child: left),
                          Positioned(right: 8, bottom: 16, child: right),
                          Positioned(
                            left: width * .08,
                            top: height * .08,
                            child: Icon(
                              icons[area],
                              size: 44,
                              color: Brand.sage,
                            ),
                          ),
                          if (picture != null && area == 'studio')
                            Positioned(
                              left: width * .37,
                              top: height * .07,
                              width: width * .27,
                              height: height * .21,
                              child: Semantics(
                                button: true,
                                label: 'Change displayed picture',
                                child: GestureDetector(
                                  onTap: () => app.change(engine.rotatePicture),
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    color: Brand.gold,
                                    child: CustomPaint(
                                      painter: StrokePainter(
                                        strokes:
                                            (picture.payload['strokes'] as List)
                                                .map(
                                                  (s) => DrawingStroke.fromJson(
                                                    Map<String, dynamic>.from(
                                                      s,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            right: 18,
                            top: height * .09,
                            child: Column(
                              children: [
                                for (final decor in engine.decorations(w))
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Tooltip(
                                      message: 'Our $decor keepsake',
                                      child: Icon(
                                        {
                                          'flower': Icons.local_florist_rounded,
                                          'blocks': Icons.toys_rounded,
                                          'star': Icons.star_rounded,
                                          'garland': Icons.celebration_rounded,
                                          'heart': Icons.favorite_rounded,
                                        }[decor],
                                        color: Brand.sage,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 12,
            children: [
              for (final room in WorldEngine.areas)
                SizedBox(
                  width: 100,
                  child: prop(
                    icons[room]!,
                    names[room]!,
                    () => app.change((w) => engine.visit(w, room)),
                    area == room ? Brand.gold : Brand.cream,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class GardenPainter extends CustomPainter {
  final bool night;
  GardenPainter({required this.night});
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..isAntiAlias = true;
    c.drawRect(
      Offset.zero & s,
      p..color = night ? const Color(0xff697c89) : Brand.sky,
    );
    c.drawCircle(
      Offset(s.width * .72, s.height * .15),
      s.width * .07,
      p..color = Brand.gold,
    );
    c.drawOval(
      Rect.fromLTWH(-s.width * .3, s.height * .5, s.width * 1.5, s.height * .9),
      p..color = Brand.mint,
    );
    c.drawOval(
      Rect.fromLTWH(s.width * .2, s.height * .67, s.width * .6, s.height * .4),
      p..color = Brand.cream,
    );
    for (var i = 0; i < 5; i++) {
      final x = s.width * (.06 + i * .2), y = s.height * (.57 + (i % 2) * .08);
      c.drawLine(
        Offset(x, y),
        Offset(x, y + 38),
        p
          ..color = Brand.sage
          ..strokeWidth = 4,
      );
      for (var petal = 0; petal < 4; petal++) {
        c.drawCircle(
          Offset(x + (petal % 2 == 0 ? -8 : 8), y + (petal < 2 ? -7 : 7)),
          10,
          p..color = i % 2 == 0 ? Brand.peach : Brand.lavender,
        );
      }
      c.drawCircle(Offset(x, y), 5, p..color = Brand.gold);
    }
  }

  @override
  bool shouldRepaint(covariant GardenPainter old) => old.night != night;
}
