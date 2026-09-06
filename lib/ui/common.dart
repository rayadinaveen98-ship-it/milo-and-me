import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/brand.dart';
import '../core/controller.dart';

class PageShell extends ConsumerWidget {
  final String title;
  final Widget child;
  final bool back;
  const PageShell({super.key, required this.title, required this.child, this.back = true});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(controllerProvider);
    return Scaffold(appBar: AppBar(title: Text(title), automaticallyImplyLeading: false,
      leading: back ? IconButton(tooltip: 'Back home', icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.go('/home')) : null,
      actions: [IconButton(tooltip: 'For grown-ups', icon: const Icon(Icons.lock_outline_rounded), onPressed: () => context.go('/parent'))]),
      body: SafeArea(child: Column(children: [
        if (app.error != null) MaterialBanner(content: Text(app.error!), actions: [TextButton(onPressed: app.dismissError, child: const Text('Okay'))]),
        Expanded(child: Align(alignment: Alignment.topCenter, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1080), child: child))),
      ])));
  }
}
class Paper extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  const Paper({super.key, required this.child, this.color = Colors.white, this.padding = const EdgeInsets.all(22)});
  @override Widget build(BuildContext context) => Container(padding: padding,
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(26), boxShadow: const [BoxShadow(color: Color(0x09344A46), offset: Offset(0, 5), blurRadius: 18)]), child: child);
}
class BigAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  const BigAction(this.label, this.icon, this.onTap, {super.key, this.color = Brand.mint});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(5), child: FilledButton.tonalIcon(
    style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Brand.ink, minimumSize: const Size(64, 60)),
    onPressed: onTap, icon: Icon(icon), label: Text(label)));
}
Future<void> showReward(BuildContext context, String title, String message) => showDialog<void>(context: context, builder: (ctx) => AlertDialog(
  backgroundColor: Brand.cream, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  icon: const Icon(Icons.auto_awesome_rounded, size: 52, color: Brand.sage), title: Text(title), content: Text(message),
  actions: [FilledButton(onPressed: () { Navigator.pop(ctx); context.go('/home'); }, child: const Text('Back to our home'))]));
