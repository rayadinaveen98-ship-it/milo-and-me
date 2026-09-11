import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../core/brand.dart';

// Renderer adapter: domain state is supplied by the controller. A Rive renderer
// can implement the same pose / outfit / colour contract later.
class PetView extends StatefulWidget {
  final int color;
  final String pose, outfit;
  final bool reducedMotion;
  final VoidCallback? onTap;
  const PetView({
    super.key,
    this.color = 0,
    this.pose = 'happy',
    this.outfit = 'none',
    this.reducedMotion = false,
    this.onTap,
  });
  @override
  State<PetView> createState() => _PetViewState();
}

class _PetViewState extends State<PetView> {
  late final PetGame game;
  @override
  void initState() {
    super.initState();
    game = PetGame();
    _configure();
  }

  void _configure() {
    if (game.pose != widget.pose) game.poseAge = 0;
    game.color = widget.color;
    game.pose = widget.pose;
    game.outfit = widget.outfit;
    game.reduced = widget.reducedMotion;
  }

  @override
  void didUpdateWidget(covariant PetView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _configure();
  }

  @override
  Widget build(BuildContext context) {
    game.reduced =
        widget.reducedMotion || MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: 'Your pet, ${widget.pose}. Tap for a cuddle.',
      button: widget.onTap != null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: GameWidget(game: game),
      ),
    );
  }
}

class PetGame extends FlameGame {
  static final Map<String, Future<ui.Image>> _textures = {};
  ui.Image? mascot, expressions, props;
  static Future<ui.Image> texture(String name) =>
      _textures.putIfAbsent(name, () async {
        final bytes = await rootBundle.load('assets/art/$name.webp');
        final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(),
          targetWidth: name == 'milo' ? 512 : 1024,
        );
        final frame = await codec.getNextFrame();
        codec.dispose();
        return frame.image;
      });
  @override
  Future<void> onLoad() async {
    mascot = await texture('milo');
    expressions = await texture('expressions');
    props = await texture('props');
  }

  double clock = 0, poseAge = 0;
  int color = 0;
  String pose = 'happy', outfit = 'none';
  bool reduced = false;
  @override
  Color backgroundColor() => Colors.transparent;
  @override
  void update(double dt) {
    super.update(dt);
    if (!reduced) {
      clock += dt.clamp(0, .05);
      poseAge += dt.clamp(0, .05);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (size.x <= 0 || size.y <= 0) return;
    canvas.save();
    final scale = math.min(size.x / 300, size.y / 300);
    canvas.translate((size.x - 300 * scale) / 2, (size.y - 300 * scale) / 2);
    canvas.scale(scale);
    if (mascot != null && expressions != null && props != null) {
      renderIllustratedMilo(
        canvas,
        mascot!,
        expressions!,
        props!,
        pose: pose,
        outfit: outfit,
        color: color,
        clock: reduced ? 0 : clock,
        reduced: reduced,
      );
      canvas.restore();
      return;
    }
    paintPet(
      canvas,
      color: Brand.petColors[color.clamp(0, 2).toInt()],
      pose: pose == 'sleep'
          ? pose
          : poseAge < 4
          ? pose
          : [
              'happy',
              'look',
              'sit',
              'walk',
              'curious',
              'laugh',
              'surprise',
              'jump',
            ][(clock ~/ 6) % 8],
      outfit: outfit,
      clock: reduced ? 0 : clock,
      reduced: reduced,
    );
    canvas.restore();
  }
}

/// Atlas-based renderer preserves the existing Flame pose/outfit adapter.
/// Textures are shared and bounded; transient motion never changes saved state.
void renderIllustratedMilo(
  Canvas c,
  ui.Image mascot,
  ui.Image expressions,
  ui.Image props, {
  required String pose,
  required String outfit,
  required int color,
  required double clock,
  required bool reduced,
}) {
  final p = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.medium;
  c.drawOval(
    const Rect.fromLTWH(76, 279, 150, 12),
    p..color = const Color(0x33000000),
  );
  p.color = Colors.white;
  final joyful = [
    'happy',
    'laugh',
    'dance',
    'jump',
    'excited',
    'proud',
    'celebrating',
  ].contains(pose);
  final sleeping = ['sleep', 'sleepy', 'asleep'].contains(pose);
  final curious = [
    'curious',
    'surprise',
    'surprised',
    'exploring',
    'worried',
    'gently worried',
  ].contains(pose);
  final focused = [
    'thinking',
    'concentrating',
    'drawing',
    'reading',
    'cooking',
    'eat',
    'eating',
  ].contains(pose);
  c.save();
  c.translate(150, 280);
  final breath = reduced ? 0.0 : math.sin(clock * 1.5) * .008;
  c.scale(1 + breath, 1 - breath);
  if (!reduced && ['dance', 'jump', 'celebrating', 'excited'].contains(pose)) {
    c.translate(0, -math.sin(clock * 3).abs() * 9);
  }
  if (!reduced && (curious || pose == 'look')) {
    c.rotate(math.sin(clock * .8) * .035);
  }
  c.translate(-150, -280);
  if (color == 1 || color == 2) {
    p.colorFilter = ColorFilter.mode(
      color == 1 ? const Color(0xffb7d7bc) : const Color(0xffd5bbef),
      BlendMode.modulate,
    );
  }
  int? frame;
  if (sleeping || (!reduced && clock % 7 > 6.86)) {
    frame = 0;
  } else if (curious) {
    frame = 1;
  } else if (joyful && pose != 'happy') {
    frame = 2;
  } else if (focused) {
    frame = 3;
  }
  if (frame == null) {
    c.drawImageRect(
      mascot,
      Rect.fromLTWH(0, 0, mascot.width.toDouble(), mascot.height.toDouble()),
      const Rect.fromLTWH(54, 0, 192, 288),
      p,
    );
  } else {
    final fw = expressions.width / 2, fh = expressions.height / 2;
    c.drawImageRect(
      expressions,
      Rect.fromLTWH((frame % 2) * fw, (frame ~/ 2) * fh, fw, fh),
      const Rect.fromLTWH(10, 0, 280, 288),
      p,
    );
  }
  p.colorFilter = null;
  final index = {
    'beret': 0,
    'explorer': 1,
    'astronaut': 2,
    'chef': 3,
    'builder': 4,
    'detective': 5,
    'doctor': 6,
    'scarf': 7,
  }[outfit];
  void prop(int i, Rect target) {
    final pw = props.width / 4, ph = props.height / 3;
    c.drawImageRect(
      props,
      Rect.fromLTWH((i % 4) * pw, (i ~/ 4) * ph, pw, ph),
      target,
      p,
    );
  }

  if (index == 2) {
    c.drawOval(
      const Rect.fromLTWH(64, 68, 177, 133),
      Paint()
        ..color = const Color(0xff93cad4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9,
    );
  } else if (index != null) {
    prop(
      index,
      outfit == 'scarf'
          ? const Rect.fromLTWH(83, 147, 130, 88)
          : outfit == 'doctor'
          ? const Rect.fromLTWH(154, 177, 46, 46)
          : outfit == 'astronaut'
          ? const Rect.fromLTWH(60, 54, 186, 150)
          : const Rect.fromLTWH(78, 18, 140, 102),
    );
  }
  if (pose == 'eat' || pose == 'eating') {
    prop(9, const Rect.fromLTWH(95, 187, 100, 85));
  }
  if (pose == 'cooking') prop(8, const Rect.fromLTWH(85, 193, 130, 90));
  if (pose == 'affection' || pose == 'cuddling') {
    prop(11, const Rect.fromLTWH(107, 181, 90, 100));
  }
  if (pose == 'wash') {
    for (var i = 0; i < 6; i++) {
      c.drawCircle(
        Offset(60 + i * 35, 210 - (reduced ? 0 : math.sin(clock + i) * 22)),
        7 + i.toDouble(),
        p..color = const Color(0x889de3ef),
      );
    }
  }
  c.restore();
}

void paintPet(
  Canvas c, {
  required Color color,
  String pose = 'happy',
  String outfit = 'none',
  double clock = 0,
  bool reduced = false,
}) {
  final p = Paint()..isAntiAlias = true;
  void oval(Rect r, Color col) {
    p.color = col;
    p.style = PaintingStyle.fill;
    c.drawOval(r, p);
  }

  void line(Offset a, Offset b, Color col, double w) {
    p
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;
    c.drawLine(a, b, p);
    p.style = PaintingStyle.fill;
  }

  oval(const Rect.fromLTWH(59, 264, 184, 19), const Color(0x19000000));
  c.save();
  final moving = !reduced;
  final bounce = moving && ['dance', 'jump', 'laugh'].contains(pose)
      ? -math.sin(clock * 5).abs() * 14
      : 0.0;
  c.translate(
    moving && pose == 'walk' ? math.sin(clock * 1.5) * 16 : 0,
    pose == 'sleep' || pose == 'sit'
        ? 8
        : bounce + (moving ? math.sin(clock * 2) * 3 : 0),
  );
  if (pose == 'curious' || pose == 'dance') {
    c.translate(150, 200);
    c.rotate(moving ? math.sin(clock * 2) * .06 : 0);
    c.translate(-150, -200);
  }

  // Leaf-shaped ears and a soft pear silhouette distinguish Milo from a cat or dog.
  c.save();
  c.translate(85, 85);
  c.rotate(-.3);
  oval(const Rect.fromLTWH(-25, -63, 48, 98), color);
  oval(const Rect.fromLTWH(-14, -47, 26, 61), Brand.peach);
  c.restore();
  c.save();
  c.translate(210, 85);
  c.rotate(.5);
  oval(const Rect.fromLTWH(-25, -63, 48, 98), color);
  oval(const Rect.fromLTWH(-14, -47, 26, 61), Brand.peach);
  c.restore();
  oval(const Rect.fromLTWH(69, 125, 164, 143), color);
  oval(const Rect.fromLTWH(43, 69, 214, 143), color);
  oval(const Rect.fromLTWH(90, 173, 118, 78), const Color(0xFFFFE2BB));
  oval(const Rect.fromLTWH(67, 241, 64, 30), color);
  oval(const Rect.fromLTWH(171, 241, 64, 30), color);
  oval(const Rect.fromLTWH(45, 183, 42, 54), color);
  oval(const Rect.fromLTWH(220, 179, 38, 57), color);
  oval(const Rect.fromLTWH(76, 144, 34, 20), Brand.peach);
  oval(const Rect.fromLTWH(194, 144, 34, 20), Brand.peach);
  final blink =
      pose == 'sleep' || pose == 'laugh' || (!reduced && clock % 5 > 4.8);
  if (blink) {
    line(const Offset(104, 128), const Offset(123, 130), Brand.ink, 5);
    line(const Offset(179, 130), const Offset(198, 128), Brand.ink, 5);
  } else {
    final gaze = pose == 'look' && !reduced ? math.sin(clock) * 4 : 0.0;
    c.save();
    c.translate(gaze, 0);
    oval(const Rect.fromLTWH(105, 114, 18, 26), Brand.ink);
    oval(const Rect.fromLTWH(179, 114, 18, 26), Brand.ink);
    oval(const Rect.fromLTWH(109, 117, 5, 7), Colors.white);
    oval(const Rect.fromLTWH(183, 117, 5, 7), Colors.white);
    c.restore();
  }
  oval(const Rect.fromLTWH(140, 140, 20, 13), Brand.ink);
  p
    ..color = Brand.ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;
  c.drawArc(const Rect.fromLTWH(131, 146, 38, 21), .15, math.pi - .3, false, p);
  p.style = PaintingStyle.fill;
  if (pose == 'surprise' || pose == 'curious') {
    oval(const Rect.fromLTWH(142, 156, 15, 18), Brand.ink);
  }
  if (pose == 'affection' || pose == 'dance') {
    for (var i = 0; i < 3; i++) {
      final heart = TextPainter(
        text: const TextSpan(
          text: '♥',
          style: TextStyle(color: Brand.peach, fontSize: 24),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      heart.paint(
        c,
        Offset(40 + i * 98.0, 48 - (reduced ? 0 : math.sin(clock * 2 + i) * 8)),
      );
    }
  }
  // Sprout tuft, the character's signature.
  oval(const Rect.fromLTWH(147, 52, 12, 24), Brand.sage);
  c.save();
  c.translate(153, 58);
  c.rotate(.7);
  oval(const Rect.fromLTWH(0, -20, 13, 27), Brand.sage);
  c.restore();
  if (outfit == 'scarf') {
    p.color = Brand.sage;
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(87, 183, 126, 20),
        const Radius.circular(10),
      ),
      p,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(181, 188, 21, 51),
        const Radius.circular(8),
      ),
      p,
    );
  }
  if (outfit == 'beret' || outfit == 'explorer') {
    oval(
      const Rect.fromLTWH(82, 62, 140, 32),
      outfit == 'beret' ? Brand.lavender : Brand.gold,
    );
    oval(
      const Rect.fromLTWH(105, 39, 95, 44),
      outfit == 'beret' ? Brand.lavender : Brand.gold,
    );
  }
  if (outfit == 'astronaut') {
    p
      ..color = const Color(0xFF86B8C5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    c.drawOval(const Rect.fromLTWH(32, 54, 236, 165), p);
    p.style = PaintingStyle.fill;
    oval(const Rect.fromLTWH(62, 91, 18, 43), const Color(0x99FFFFFF));
  }
  if (outfit == 'chef') {
    oval(const Rect.fromLTWH(86, 38, 130, 54), Colors.white);
    oval(const Rect.fromLTWH(107, 20, 84, 55), Colors.white);
    line(const Offset(98, 80), const Offset(205, 80), Brand.cream, 12);
  }
  if (outfit == 'builder' || outfit == 'detective') {
    oval(
      const Rect.fromLTWH(91, 36, 122, 64),
      outfit == 'builder' ? Brand.gold : Brand.sage,
    );
    line(
      const Offset(77, 86),
      const Offset(226, 86),
      outfit == 'builder' ? Brand.gold : Brand.sage,
      14,
    );
  }
  if (outfit == 'doctor') {
    oval(const Rect.fromLTWH(174, 192, 35, 35), Colors.white);
    line(const Offset(191, 199), const Offset(191, 220), Brand.sage, 5);
    line(const Offset(181, 210), const Offset(201, 210), Brand.sage, 5);
  }
  if (pose == 'wash') {
    for (var i = 0; i < 7; i++) {
      oval(
        Rect.fromCircle(
          center: Offset(48 + i * 33.0, 184 - math.sin(clock * 2 + i) * 25),
          radius: 10 + i % 3 * 3.0,
        ),
        const Color(0x99D2E5EC),
      );
    }
  }
  if (pose == 'eat') {
    oval(const Rect.fromLTWH(130, 189, 42, 43), Brand.peach);
    line(const Offset(151, 183), const Offset(153, 193), Brand.sage, 5);
  }
  if (pose == 'sleep') {
    final t = TextPainter(
      text: const TextSpan(
        text: 'z z Z',
        style: TextStyle(
          color: Brand.sage,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    t.paint(c, const Offset(217, 38));
  }
  c.restore();
}
