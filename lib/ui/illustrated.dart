import 'package:flutter/material.dart';
import '../core/brand.dart';

class SceneArt extends StatelessWidget {
  final String name;
  final BoxFit fit;
  const SceneArt(this.name, {super.key, this.fit = BoxFit.fill});
  @override
  Widget build(BuildContext context) => Image.asset('assets/art/$name.webp',
    fit: fit, width: double.infinity, height: double.infinity,
    cacheWidth: 768, excludeFromSemantics: true);
}

class SpeechLeaf extends StatelessWidget {
  final String text;
  const SpeechLeaf({super.key, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    decoration: BoxDecoration(color: Brand.cream.withValues(alpha: .96),
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(24),
        topRight: Radius.circular(24), bottomRight: Radius.circular(24), bottomLeft: Radius.circular(5)),
      boxShadow: const [BoxShadow(color: Color(0x33243938), blurRadius: 16, offset: Offset(0, 5))]),
    child: Text(text, textAlign: TextAlign.center,
      style: const TextStyle(color: Brand.ink, fontSize: 16, fontWeight: FontWeight.w600)));
}

class WorldHotspot extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const WorldHotspot({super.key, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Tooltip(message: label,
    child: Semantics(label: label, button: true,
      child: Material(color: Colors.transparent, child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(30),
        splashColor: Brand.gold.withValues(alpha: .3),
        child: Align(alignment: Alignment.bottomCenter,
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Brand.cream.withValues(alpha: .94),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x44243938), blurRadius: 10)]),
            child: Text(label, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Brand.ink)))))));
}
