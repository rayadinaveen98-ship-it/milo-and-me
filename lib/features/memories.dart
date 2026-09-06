import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../ui/common.dart';

class MemoriesScreen extends ConsumerWidget {
  const MemoriesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(controllerProvider).world;
    return PageShell(
      title: 'Our book of little wonders',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            '${w.petName} & ${w.nickname}',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Every adventure has a place here.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final first in w.companion.firsts.where(
                (s) =>
                    s.contains('theme:') ||
                    [
                      'creativity-five',
                      'puzzle-explorer',
                      'kindness',
                    ].contains(s),
              ))
                Chip(
                  avatar: const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    {
                          'creativity-five': 'Our little art gallery',
                          'puzzle-explorer': 'Five ways to wonder',
                          'kindness': 'A kindness memory',
                        }[first] ??
                        first.replaceFirst('theme:', 'Our ') + ' discoveries',
                  ),
                ),
            ],
          ),
          if (w.memories.isEmpty)
            const Paper(
              color: Brand.lavender,
              child: Column(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 60, color: Brand.sage),
                  SizedBox(height: 16),
                  Text(
                    'Our first page is waiting. Shall we make a picture together?',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          for (final m in w.memories.reversed)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Paper(
                color: m.kind == 'drawing'
                    ? Colors.white
                    : m.kind == 'story'
                    ? Brand.lavender
                    : Brand.sky,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          m.kind == 'drawing'
                              ? Icons.palette_rounded
                              : m.kind == 'story'
                              ? Icons.auto_stories_rounded
                              : m.kind == 'outfit'
                              ? Icons.checkroom_rounded
                              : Icons.extension_rounded,
                          color: Brand.sage,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            m.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    if (m.payload['thumbnail'] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.memory(
                              base64Decode(m.payload['thumbnail']),
                              height: 240,
                              fit: BoxFit.contain,
                              semanticLabel: m.title,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      '${m.at.day}.${m.at.month}.${m.at.year}  ·  Made a memory together',
                      style: const TextStyle(color: Brand.ink),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
