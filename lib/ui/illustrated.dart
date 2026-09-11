import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../core/brand.dart';
import 'pet.dart';

String artForTheme(dynamic theme) => switch (theme) {
  'Space' => 'space',
  'Dinosaurs' => 'dinosaurs',
  'Ocean' => 'ocean',
  'Animals' => 'garden',
  'Nature' => 'garden',
  _ => 'studio',
};

class SymbolArt extends StatelessWidget {
  final String value;
  final double size;
  const SymbolArt(this.value, {super.key, this.size = 56});
  static const objects = {
    'leaf': 0,
    'shell': 1,
    'star': 2,
    'flower': 3,
    'rocket': 4,
    'planet': 5,
    'moon': 6,
    'fish': 7,
    'dinosaur': 8,
    'apple': 9,
    'tree': 10,
    'seed': 11,
    'butterfly': 12,
    'egg': 13,
    'feather': 14,
    'footprint': 15,
    '★': 2,
    '✦': 2,
    '☾': 6,
    '❧': 0,
  };
  @override
  Widget build(BuildContext context) {
    final index = objects[value.toLowerCase()];
    const shapes = {
      '■': Icons.square_rounded,
      '□': Icons.crop_square_rounded,
      '●': Icons.circle,
      '○': Icons.circle_outlined,
      '▲': Icons.change_history_rounded,
      '△': Icons.change_history_rounded,
      '☆': Icons.star_outline_rounded,
      '♡': Icons.favorite_border_rounded,
      '♥': Icons.favorite_rounded,
      '▮': Icons.rectangle_rounded,
      '?': Icons.question_mark_rounded,
    };
    final tokens = value.replaceAll(' ', '').split('');
    if (tokens.length > 1 &&
        tokens.every(
          (token) => shapes.containsKey(token) || objects.containsKey(token),
        )) {
      return Semantics(
        label: value,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 5,
          runSpacing: 5,
          children: [for (final token in tokens) SymbolArt(token, size: 26)],
        ),
      );
    }
    if (shapes.containsKey(value)) {
      return Semantics(
        label: value,
        child: Icon(
          shapes[value],
          size: size.clamp(24, 46).toDouble(),
          color: Brand.ink,
        ),
      );
    }
    return Semantics(
      label: value,
      child: index == null
          ? Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, color: Brand.ink),
            )
          : SizedBox(
              width: size,
              height: size,
              child: ArtObject(index, atlas: 'pieces', columns: 4, rows: 4),
            ),
    );
  }
}

class ArtObject extends StatelessWidget {
  final int index;
  final String atlas;
  final int columns, rows;
  const ArtObject(
    this.index, {
    super.key,
    this.atlas = 'props',
    this.columns = 4,
    this.rows = 3,
  });
  @override
  Widget build(BuildContext context) => FutureBuilder<ui.Image>(
    future: PetGame.texture(atlas),
    builder: (context, snapshot) => snapshot.hasData
        ? CustomPaint(
            size: const Size(180, 180),
            painter: _AtlasPainter(snapshot.data!, index, columns, rows),
          )
        : const SizedBox(),
  );
}

class _AtlasPainter extends CustomPainter {
  final ui.Image image;
  final int index;
  final int columns, rows;
  _AtlasPainter(this.image, this.index, this.columns, this.rows);
  @override
  void paint(Canvas canvas, Size size) {
    final w = image.width / columns, h = image.height / rows;
    // Two wide neighboring props cross their nominal cells in the source atlas.
    // Explicit source bounds keep their thumbnails isolated without repainting art.
    final source = columns == 4 && rows == 3 && index == 6
        ? Rect.fromLTWH(
            image.width * .539,
            image.height * .366,
            image.width * .215,
            image.height * .261,
          )
        : columns == 4 && rows == 3 && index == 5
        ? Rect.fromLTWH(
            image.width * .267,
            image.height * .366,
            image.width * .263,
            image.height * .261,
          )
        : Rect.fromLTWH(
            (index % columns) * w + 5,
            (index ~/ columns) * h + 5,
            w - 10,
            h - 10,
          );
    canvas.drawImageRect(
      image,
      source,
      Alignment.center.inscribe(
        applyBoxFit(BoxFit.contain, source.size, size).destination,
        Offset.zero & size,
      ),
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant _AtlasPainter old) =>
      old.image != image || old.index != index;
}

class SceneArt extends StatelessWidget {
  final String name;
  final BoxFit fit;
  const SceneArt(this.name, {super.key, this.fit = BoxFit.fill});
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/art/$name.webp',
    fit: fit,
    width: double.infinity,
    height: double.infinity,
    cacheWidth: 768,
    excludeFromSemantics: true,
  );
}

class SpeechLeaf extends StatelessWidget {
  final String text;
  const SpeechLeaf({super.key, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    decoration: BoxDecoration(
      color: Brand.cream.withValues(alpha: .96),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
        bottomLeft: Radius.circular(5),
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33243938),
          blurRadius: 16,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Brand.ink,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class WorldHotspot extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const WorldHotspot({super.key, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Semantics(
      label: label,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          splashColor: Brand.gold.withValues(alpha: .3),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Brand.cream.withValues(alpha: .94),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x44243938), blurRadius: 10),
                ],
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Brand.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
