import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../domain/models.dart';
import '../domain/engines.dart';
import '../domain/pack_media.dart';
import 'database.dart';

class ContentRepository {
  final AppDatabase db;
  final http.Client Function() clientFactory;
  ContentRepository(this.db, {http.Client Function()? clientFactory})
    : clientFactory = clientFactory ?? http.Client.new;
  late Json seed;
  List<Json> installed = [];
  int _epoch = 0;
  void invalidateDownloads() { _epoch++; installed.clear(); }
  Future<void> load() async {
    seed = jsonDecode(
      await rootBundle.loadString('assets/content/meadow.json'),
    );
    ContentEngine.validate(seed);
    installed = [];
    for (final p in await db.packs()) {
      try { ContentEngine.validate(p); installed.add(p); }
      catch (_) { /* Retain bundled fallback for quarantined content. */ }
    }
  }

  Future<Uint8List?> mediaBytes(String reference) async {
    final parts = reference.split(':');
    if (parts.length != 3 || parts.first != 'pack') return null;
    final raw = await db.readMedia(parts[1], parts[2]);
    if (raw == null) return null;
    final bytes = base64Decode(raw['data']);
    if (bytes.length != raw['bytes'] || sha256.convert(bytes).toString() != raw['sha256']) throw const FormatException('Media integrity failed');
    return bytes;
  }
  Future<Source> audioSource(String reference) async {
    if (!reference.startsWith('pack:')) return AssetSource(reference);
    final bytes = await mediaBytes(reference);
    if (bytes == null) throw StateError('Narration unavailable');
    return BytesSource(bytes);
  }
  Future<void> uninstall(String id) async { await db.removePack(id); installed.removeWhere((p) => p['id'] == id); }
  List<Json> list(String type) => [seed, ...installed]
      .expand(
        (p) =>
            (p[type] as List? ?? []).map((v) => Map<String, dynamic>.from(v)),
      )
      .toList();
  Json? find(String type, String id) {
    for (final item in list(type)) {
      if (item['id'] == id) return item;
    }
    return null;
  }

  // Parent-owned catalogue must supply a trusted HTTPS URL and SHA-256.
  // A pack is one bounded JSON document, avoiding archive traversal entirely.
  Future<void> download({
    required Uri url,
    required String expectedHash,
    required String expectedId,
    required int expectedVersion,
    required void Function(int received, int? total) progress,
  }) async {
    final epoch = _epoch;
    if (url.scheme != 'https' ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(expectedHash)) {
      throw const FormatException('Invalid pack source');
    }
    final client = clientFactory();
    try {
      final request = http.Request('GET', url)..followRedirects = false;
      final response = await client
          .send(request)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) throw StateError('Pack unavailable');
      const maxBytes = 8 * 1024 * 1024;
      if ((response.contentLength ?? 0) > maxBytes) {
        throw const FormatException('Pack too large');
      }
      final bytes = <int>[];
      await for (final chunk in response.stream.timeout(
        const Duration(seconds: 20),
      )) {
        bytes.addAll(chunk);
        if (bytes.length > maxBytes) {
          throw const FormatException('Pack too large');
        }
        progress(bytes.length, response.contentLength);
      }
      if (sha256.convert(bytes).toString() != expectedHash) {
        throw const FormatException('Pack integrity check failed');
      }
      final pack = Map<String, dynamic>.from(jsonDecode(utf8.decode(bytes)));
      ContentEngine.validate(pack);
      PackMedia.validate(pack, requireData: true);
      if (pack['id'] != expectedId || pack['version'] != expectedVersion) {
        throw const FormatException('Pack identity mismatch');
      }
      final existing = [seed, ...installed];
      if (existing.any(
        (p) =>
            p['id'] == pack['id'] && (p['version'] as int) >= expectedVersion,
      )) {
        throw const FormatException('Pack is already current');
      }
      for (final type in [
        'drawings',
        'puzzles',
        'stories',
        'cooking',
        'roleplay',
        'science',
      ]) {
        final otherIds = existing
            .where((p) => p['id'] != pack['id'])
            .expand((p) => (p[type] as List? ?? []).map((v) => v['id']))
            .toSet();
        if ((pack[type] as List? ?? []).any(
          (v) => otherIds.contains(v['id']),
        )) {
          throw const FormatException('Conflicting content identity');
        }
      }
      if (epoch != _epoch) throw StateError('Download cancelled by data reset');
      await db.storePack(pack);
      final active = await db.packs();
      if (epoch == _epoch) installed = active;
    } finally {
      client.close();
    }
  }
}
