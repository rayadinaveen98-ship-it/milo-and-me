import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/controller.dart';
import '../domain/models.dart';
import '../features/drawing.dart';

class CreationPreview extends ConsumerStatefulWidget {
  final Memory memory;
  const CreationPreview({super.key, required this.memory});
  @override ConsumerState<CreationPreview> createState() => _CreationPreviewState();
}
class _CreationPreviewState extends ConsumerState<CreationPreview> {
  late Future<Json?> payload;
  void load() { payload = widget.memory.payload['creationId'] is String ? ref.read(controllerProvider).db.readCreation(widget.memory.id) : Future.value(widget.memory.payload); }
  @override void initState() { super.initState(); load(); }
  @override void didUpdateWidget(CreationPreview oldWidget) { super.didUpdateWidget(oldWidget); if (oldWidget.memory.id != widget.memory.id) load(); }
  @override Widget build(BuildContext context) => FutureBuilder<Json?>(future: payload, builder: (context, s) {
    final p = s.data;
    if (p == null) return const Center(child: Icon(Icons.palette_outlined));
    if (p['thumbnail'] is String) {
      return Image.memory(base64Decode(p['thumbnail']), fit: BoxFit.contain, cacheWidth: 256, semanticLabel: widget.memory.title, errorBuilder: (_, _, _) => const Icon(Icons.palette_outlined));
    }
    return CustomPaint(painter: StrokePainter(strokes: (p['strokes'] as List? ?? []).map((s) => DrawingStroke.fromJson(Map<String,dynamic>.from(s))).toList()));
  });
}
