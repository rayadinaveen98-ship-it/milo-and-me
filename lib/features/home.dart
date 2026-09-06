import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../domain/engines.dart';
import '../domain/models.dart';
import '../ui/common.dart';
import '../ui/pet.dart';
import 'drawing.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(controllerProvider), w = app.world;
    final night = DateTime.now().hour >= 19 || DateTime.now().hour < 6;
    final drawings = w.memories.where((m) => m.kind == 'drawing').toList();
    return PageShell(title: '${w.petName} & ${w.nickname}', back: false, child: ListView(padding: const EdgeInsets.fromLTRB(18, 0, 18, 24), children: [
      Text(night ? 'A cosy evening together' : 'Our little corner of the world', textAlign: TextAlign.center, style: const TextStyle(color: Brand.sage, fontSize: 16)),
      const SizedBox(height: 12),
      Paper(color: Brand.mint, padding: const EdgeInsets.all(16), child: Text(w.dialogue, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
      const SizedBox(height: 10),
      LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth > 650;
        return AspectRatio(aspectRatio: wide ? 1.5 : .91, child: ClipRRect(borderRadius: BorderRadius.circular(32), child: LayoutBuilder(builder: (context, box) {
          final width = box.maxWidth, height = box.maxHeight;
          Widget spot(double x, double y, IconData icon, String label, String route, {Color color = Brand.cream}) => Positioned(left: width * x, top: height * y,
            child: Semantics(label: label, button: true, child: Column(children: [IconButton.filledTonal(tooltip: label,
              style: IconButton.styleFrom(backgroundColor: color, foregroundColor: Brand.ink, minimumSize: const Size(64, 60)),
              onPressed: () => context.go(route), icon: Icon(icon, size: 32)), Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))])));
          return Stack(children: [
            Positioned.fill(child: CustomPaint(painter: RoomPainter(night: night))),
            if (drawings.isNotEmpty) Positioned(left: width * .4, top: height * .10, width: width * .20, height: height * .16,
              child: GestureDetector(onTap: () => context.go('/memories'), child: Semantics(label: 'Your latest picture on our wall', button: true,
                child: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: Brand.gold, borderRadius: BorderRadius.circular(9)),
                  child: CustomPaint(painter: StrokePainter(strokes: (drawings.last.payload['strokes'] as List).map((s) => DrawingStroke.fromJson(Map<String,dynamic>.from(s))).toList())))))),
            Positioned(left: width * .20, top: height * .28, width: width * .60, height: height * .48, child: PetView(color: w.color, pose: w.mood, outfit: w.outfit,
              reducedMotion: w.reducedMotion || MediaQuery.disableAnimationsOf(context), onTap: () => app.care('cuddle'))),
            spot(.04, .31, Icons.brush_rounded, 'Art corner', '/drawings', color: Brand.peach),
            spot(.73, .34, Icons.auto_stories_rounded, 'Stories', '/stories', color: Brand.lavender),
            spot(.05, .67, Icons.extension_rounded, 'Puzzles', '/puzzles', color: Brand.gold),
            spot(.70, .70, Icons.checkroom_rounded, 'Dress up', '/wardrobe', color: Brand.sky),
            spot(.70, .07, Icons.photo_album_rounded, 'Memories', '/memories'),
          ]);
        })));
      }),
      const SizedBox(height: 12),
      Wrap(alignment: WrapAlignment.center, children: [
        BigAction('Picnic', Icons.apple_rounded, () => app.care('food'), color: Brand.peach),
        BigAction('Bubbles', Icons.bubble_chart_rounded, () => app.care('wash'), color: Brand.sky),
        BigAction(w.mood == 'sleep' ? 'Wake up' : 'Rest', Icons.bedtime_rounded, () => app.care(w.mood == 'sleep' ? 'cuddle' : 'sleep'), color: Brand.lavender),
      ]),
      if (w.memories.isEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: FilledButton.icon(onPressed: () => context.go('/drawing/flower'), icon: const Icon(Icons.local_florist_rounded), label: const Text('Draw our first flower'))),
      TextButton.icon(onPressed: () => app.change((next) { next.dialogue = PetEngine().suggestion(next, hour: DateTime.now().hour, sessionMinutes: app.elapsedSeconds ~/ 60); return next; }), icon: const Icon(Icons.lightbulb_outline_rounded), label: Text('What shall we do, ${w.petName}?')),
    ]));
  }
}
class RoomPainter extends CustomPainter {
  final bool night;
  RoomPainter({required this.night});
  @override void paint(Canvas c, Size s) {
    final p = Paint();
    void rect(double x, double y, double w, double h, Color color, [double r = 0]) { p.color = color; c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x*s.width,y*s.height,w*s.width,h*s.height), Radius.circular(r)),p); }
    rect(0,0,1,1,night ? const Color(0xFFD5DBDB) : const Color(0xFFF3EAD4));
    for (var i = 0; i < 12; i++) { rect(i/12,0,.002,.72,const Color(0x14638A72)); }
    rect(0,.72,1,.28,const Color(0xFFE1C8A1)); rect(0,.71,1,.02,const Color(0xFFC2A985));
    for (var i = 0; i < 5; i++) { rect(0,.76+i*.06,1,.002,const Color(0x20A3835A)); }
    rect(.08,.065,.24,.24,Brand.cream,45); rect(.10,.08,.20,.20,night ? const Color(0xFF526778) : Brand.sky,40);
    p.color = night ? Brand.cream : Brand.gold; c.drawCircle(Offset(s.width*.22,s.height*.14),s.width*.035,p);
    rect(.195,.08,.008,.21,Brand.cream); rect(.10,.18,.20,.008,Brand.cream);
    p.color = const Color(0xFFB9CDB6); c.drawOval(Rect.fromLTWH(s.width*.19,s.height*.67,s.width*.62,s.height*.18),p);
    p..color = const Color(0x80FFFFFF)..style = PaintingStyle.stroke..strokeWidth = 3; c.drawOval(Rect.fromLTWH(s.width*.24,s.height*.695,s.width*.52,s.height*.13),p); p.style = PaintingStyle.fill;
    rect(.71,.28,.24,.02,const Color(0xFFA98868),4);
    for (var i=0;i<4;i++) { rect(.74+i*.04,.20-i*.008,.025,.08+i*.008,[Brand.peach,Brand.sage,Brand.lavender,Brand.gold][i],3); }
    rect(.04,.47,.20,.02,const Color(0xFFB8966C),5);
    rect(.06,.49,.012,.12,const Color(0xFFB8966C)); rect(.20,.49,.012,.12,const Color(0xFFB8966C));
  }
  @override bool shouldRepaint(covariant RoomPainter old) => old.night != night;
}
