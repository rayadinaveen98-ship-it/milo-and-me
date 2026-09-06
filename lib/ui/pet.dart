import 'dart:math' as math;
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
  Widget build(BuildContext context) => Semantics(
    label: 'Your pet, ${widget.pose}. Tap for a cuddle.',
    button: widget.onTap != null,
    child: GestureDetector(
      onTap: widget.onTap,
      child: GameWidget(game: game),
    ),
  );
}

class PetGame extends FlameGame {
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
  if(outfit=='chef') {
    oval(const Rect.fromLTWH(86,38,130,54),Colors.white);
    oval(const Rect.fromLTWH(107,20,84,55),Colors.white);
    line(const Offset(98,80),const Offset(205,80),Brand.cream,12);
  }
  if(outfit=='builder'||outfit=='detective') {
    oval(const Rect.fromLTWH(91,36,122,64),outfit=='builder'?Brand.gold:Brand.sage);
    line(const Offset(77,86),const Offset(226,86),outfit=='builder'?Brand.gold:Brand.sage,14);
  }
  if(outfit=='doctor') {
    oval(const Rect.fromLTWH(174,192,35,35),Colors.white);
    line(const Offset(191,199),const Offset(191,220),Brand.sage,5);
    line(const Offset(181,210),const Offset(201,210),Brand.sage,5);
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
