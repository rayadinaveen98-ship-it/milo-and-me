import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../domain/science_engine.dart';
import '../ui/common.dart';
import '../ui/pet.dart';

class ScienceCatalogue extends ConsumerWidget {
  const ScienceCatalogue({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(controllerProvider).content.list('science');
    return PageShell(title: 'Little discoveries', child: ListView.builder(
      padding: const EdgeInsets.all(24), itemCount: items.length,
      itemBuilder: (context, i) {
        final d = items[i];
        return Padding(padding: const EdgeInsets.only(bottom: 14), child: Paper(
          color: d['safety'] == 'A' ? Brand.sky : Brand.mint,
          child: ListTile(contentPadding: EdgeInsets.zero,
            leading: Icon(d['safety'] == 'A' ? Icons.science_rounded : d['safety'] == 'C' ? Icons.family_restroom_rounded : Icons.visibility_rounded, size: 38),
            title: Text(d['title']), subtitle: Text({'A': 'Explore on screen', 'B': 'Notice or imagine · optional', 'C': 'Together with a grown-up'}[d['safety']]!),
            onTap: () => context.go('/science/${d['id']}'))));
      }));
  }
}

class ScienceScreen extends ConsumerStatefulWidget {
  final String id;
  const ScienceScreen({super.key, required this.id});
  @override
  ConsumerState<ScienceScreen> createState() => _ScienceState();
}
class _ScienceState extends ConsumerState<ScienceScreen> {
  final pin = TextEditingController();
  late AppController app;
  bool busy = false;
  String? choice, feedback, gateError;
  int selectedRound = -1;
  @override
  void initState() { super.initState(); app = ref.read(controllerProvider); }
  @override
  void dispose() { app.endScience(); pin.dispose(); super.dispose(); }
  Future<void> authorize() async {
    setState(() { busy = true; gateError = null; });
    try {
      final ok = await app.authorizeScience(widget.id, pin.text);
      pin.clear();
      if (mounted && !ok) setState(() => gateError = 'The PIN did not match.');
    } catch (_) {
      if (mounted) setState(() => gateError = 'Please wait a minute, then try your parent PIN again.');
    } finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) {
    ref.watch(controllerProvider);
    final d = app.content.find('science', widget.id);
    if (d == null) return const PageShell(title: 'Discoveries', child: Center(child: Text('Choose another discovery from our garden.')));
    if (d['safety'] == 'C' && !app.adultActivity.allows(widget.id)) {
      return PageShell(title: 'Together with a grown-up', child: ListView(padding: const EdgeInsets.all(24), children: [
        const Icon(Icons.family_restroom_rounded, size: 72, color: Brand.sage),
        const SizedBox(height: 20),
        const Paper(color: Brand.mint, child: Text(ScienceEngine.adultRole)),
        const SizedBox(height: 20),
        const Text('A grown-up enters their PIN and stays for this activity. Permission ends when you leave or the app backgrounds.'),
        TextField(controller: pin, obscureText: true, maxLength: 6, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'Parent PIN')),
        if (gateError != null) Text(gateError!),
        FilledButton(onPressed: busy ? null : authorize, child: const Text('I’m the grown-up and will stay')),
        TextButton(onPressed: () => context.go('/science'), child: const Text('Choose a digital discovery')),
      ]));
    }
    final engine = ScienceEngine(), p = engine.progress(app.world, widget.id);
    final done = engine.complete(d, p), index = p['index'] as int;
    if (selectedRound != index) { selectedRound = index; choice = null; feedback = null; }
    final isDigital = d['safety'] == 'A';
    return PageShell(title: d['title'], child: ListView(padding: const EdgeInsets.all(24), children: [
      if (d['safety'] == 'C') const Paper(color: Brand.mint, child: Text('Stay together with your grown-up. Looking or using paper leaves is enough.')),
      SizedBox(height: 230, child: Stack(children: [
        Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(28), child: CustomPaint(painter: DiscoveryPainter(template: d['template'], choice: choice, round: index)))),
        Positioned(right: 0, bottom: 0, width: 120, height: 130, child: PetView(color: app.world.color, outfit: app.world.outfit, pose: done ? 'happy' : 'curious', reducedMotion: app.world.reducedMotion || MediaQuery.disableAnimationsOf(context))),
      ])),
      const SizedBox(height: 20),
      Paper(color: Brand.mint, child: Text(done ? 'We noticed something together. Our discovery is in our memory book.' : engine.prompt(d, index), textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge)),
      const SizedBox(height: 18),
      if (!done) ...[
        if (isDigital) const Text('Try either choice and watch what changes.', textAlign: TextAlign.center),
        Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 12, children: [
          for (final option in engine.options(d, index)) FilledButton.tonal(onPressed: busy ? null : () => setState(() { choice = option; feedback = engine.response(d, index, option); }), child: Padding(padding: const EdgeInsets.all(10), child: Text(option))),
        ]),
        if (feedback != null) Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text(feedback!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20))),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: choice == null || busy ? null : () async {
          setState(() => busy = true);
          final ok = await app.observeScience(d, choice!);
          if (mounted) setState(() { busy = false; if (!ok) feedback = 'Please try again. Your earlier discoveries are safe.'; });
        }, icon: const Icon(Icons.check_rounded), label: const Text('Keep our discovery')),
      ] else ...[
        const Text('If you like, draw a discovery on paper or make a pattern with your blocks. Our next adventure can wait.', textAlign: TextAlign.center),
        TextButton(onPressed: () => app.replayScenario('science', widget.id), child: const Text('Explore again')),
        FilledButton(onPressed: () => context.go('/world'), child: const Text('Back to our garden')),
      ],
      if (!isDigital) const Padding(padding: EdgeInsets.only(top: 16), child: Text('No photo, location or proof needed. You may stop or imagine instead at any time.', textAlign: TextAlign.center)),
    ]));
  }
}

class DiscoveryPainter extends CustomPainter {
  final String template;
  final String? choice;
  final int round;
  DiscoveryPainter({required this.template, required this.choice, required this.round});
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..isAntiAlias = true;
    c.drawRect(Offset.zero & s, p..color = Brand.sky);
    final center = Offset(s.width * .36, s.height * .52);
    void label(String text, Offset at) {
      final painter = TextPainter(text: TextSpan(text: text, style: const TextStyle(fontSize: 30, color: Brand.ink)), textDirection: TextDirection.ltr)..layout(maxWidth: s.width * .65);
      painter.paint(c, at);
    }
    switch (template) {
      case 'colour':
        final base = round == 0 ? const Color(0xffffdb41) : round == 1 ? const Color(0xff608ae0) : const Color(0xff65a776);
        final mixed = choice == null ? base : round == 0 ? (choice == 'Red' ? const Color(0xffef9a44) : const Color(0xff6aa669)) : round == 1 ? (choice == 'Red' ? const Color(0xffa083bb) : const Color(0xff6aa669)) : (choice == 'More white' ? const Color(0xffd8ebdc) : const Color(0xffa0c9aa));
        c.drawCircle(center, 65, p..color = mixed);
        c.drawCircle(Offset(s.width * .16, 40), 22, p..color = base);
        break;
      case 'shadow':
        final near = choice == 'Near', right = choice == 'Right';
        c.drawCircle(Offset(right ? s.width * .7 : 24, 45), 22, p..color = Brand.gold);
        c.drawOval(Rect.fromCenter(center: center + Offset(right ? -35 : 35, 45), width: near ? 160 : 90, height: 25), p..color = choice == 'Clear glass' ? const Color(0xffb2c6c8) : const Color(0xff65747c));
        c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 40, height: 70), const Radius.circular(8)), p..color = Brand.peach);
        break;
      case 'float':
        c.drawRect(Rect.fromLTWH(0, 95, s.width, s.height-95), p..color = const Color(0xff83bdcf));
        final sinks = ['Stone', 'Ball', 'Add weight'].contains(choice);
        c.drawOval(Rect.fromCenter(center: Offset(center.dx, sinks ? 190 : 95), width: 70, height: 30), p..color = sinks ? Brand.sage : Brand.gold);
        break;
      case 'plant':
        c.drawRect(Rect.fromLTWH(0, 180, s.width, 50), p..color = Brand.peach);
        c.drawLine(Offset(center.dx, 185), Offset(center.dx, 150 - round.clamp(0, 2) * 40.0), p..color = Brand.sage..strokeWidth = 7);
        for (var i = 0; i <= round.clamp(0, 2); i++) { c.drawOval(Rect.fromLTWH(center.dx - 35, 130 - i * 32.0, 40, 20), p..color = Brand.sage); }
        break;
      case 'magnet':
        label('N     S', const Offset(30, 35));
        final attracts = ['Iron nail', 'Steel clip', 'Opposite poles'].contains(choice);
        c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(30, 80, 65, 55), const Radius.circular(12)), p..color = Brand.peach);
        c.drawCircle(Offset(attracts ? 105 : 190, 105), 20, p..color = Brand.sage);
        label(choice == 'Same poles' ? '↔' : attracts ? '←' : '○', const Offset(125, 140));
        break;
      case 'water':
        c.drawOval(const Rect.fromLTWH(20, 160, 170, 30), p..color = const Color(0xff77b2cd));
        c.drawOval(const Rect.fromLTWH(50, 25, 130, 45), p..color = Colors.white);
        label(round == 0 ? '↑ ↑' : round == 1 ? '☁' : '↓ ↓', const Offset(65, 85));
        break;
      default:
        for (var i = 0; i < 6; i++) {
          final at = Offset(35 + (i % 3) * 65.0, 65 + (i ~/ 3) * 70.0);
          if (i.isEven) { c.drawOval(Rect.fromCenter(center: at, width: 30, height: 48), p..color = choice == null ? Brand.sage : Brand.peach); }
          else { c.drawCircle(at, 18, p..color = Brand.gold); }
        }
    }
  }
  @override
  bool shouldRepaint(covariant DiscoveryPainter old) => old.template != template || old.choice != choice || old.round != round;
}
