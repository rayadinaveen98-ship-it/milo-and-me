import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/controller.dart';

class PackBackground extends ConsumerStatefulWidget {
  final String reference;
  const PackBackground({super.key, required this.reference});
  @override
  ConsumerState<PackBackground> createState() => _PackBackgroundState();
}

class _PackBackgroundState extends ConsumerState<PackBackground> {
  late Future<Uint8List?> bytes;
  void load() {
    bytes = ref.read(controllerProvider).content.mediaBytes(widget.reference);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void didUpdateWidget(PackBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reference != widget.reference) load();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
    future: bytes,
    builder: (c, s) => s.hasData
        ? Image.memory(
            s.data!,
            height: 160,
            fit: BoxFit.cover,
            cacheWidth: 900,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          )
        : const SizedBox.shrink(),
  );
}
