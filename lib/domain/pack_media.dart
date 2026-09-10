import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'models.dart';

class PackMedia {
  static void validate(Json pack, {bool requireData = false}) {
    final manifest = pack['manifest'];
    if (manifest != null && (manifest is! Map || manifest['schema'] != 1 || manifest['id'] != pack['id'] || manifest['version'] != pack['version'] || manifest['language'] != 'en')) throw const FormatException('Invalid pack manifest');
    final media = pack['media'] ?? [];
    if (media is! List || media.length > 64) throw const FormatException('Invalid media catalogue');
    final ids = <String>{};
    var total = 0;
    for (final raw in media) {
      if (raw is! Map || raw['id'] is! String || !RegExp(r'^[a-z0-9_-]{1,64}$').hasMatch(raw['id']) || !ids.add(raw['id']) || !['image/png','audio/wav','audio/mpeg'].contains(raw['mime']) || raw['sha256'] is! String || !RegExp(r'^[a-f0-9]{64}$').hasMatch(raw['sha256']) || raw['bytes'] is! int || raw['bytes'] <= 0 || raw['bytes'] > 2 * 1024 * 1024) throw const FormatException('Invalid media entry');
      total += raw['bytes'] as int;
      if (total > 5 * 1024 * 1024) throw const FormatException('Media budget exceeded');
      if (requireData || raw['data'] != null) {
        if (raw['data'] is! String) throw const FormatException('Missing media bytes');
        final bytes = base64Decode(raw['data']);
        if (bytes.length != raw['bytes'] || sha256.convert(bytes).toString() != raw['sha256']) throw const FormatException('Media integrity failed');
        if (raw['mime'] == 'image/png' && (bytes.length < 24 || bytes[0] != 137 || ascii.decode(bytes.sublist(1,4), allowInvalid: true) != 'PNG')) throw const FormatException('Invalid PNG');
        if (raw['mime'] == 'image/png') { final dims = ByteData.sublistView(bytes); if (dims.getUint32(16) > 2048 || dims.getUint32(20) > 2048) throw const FormatException('Image dimensions too large'); }
      }
    }
    void references(dynamic node) {
      if (node is Map) {
        for (final entry in node.entries) {
          if (['audio','backgroundAsset'].contains(entry.key) && entry.value is String && (entry.value as String).startsWith('pack:')) {
            final parts = (entry.value as String).split(':');
            if (parts.length != 3 || parts[1] != pack['id'] || !ids.contains(parts[2])) throw const FormatException('Unknown pack asset');
            final target = media.firstWhere((m) => m['id'] == parts[2]);
            if (!(target['mime'] as String).startsWith(entry.key == 'audio' ? 'audio/' : 'image/')) throw const FormatException('Wrong media kind');
          }
          references(entry.value);
        }
      } else if (node is List) { for (final value in node) { references(value); } }
    }
    for (final type in ['drawings','stories','puzzles']) { references(pack[type]); }
    final rewards = pack['rewards'] ?? [];
    if (rewards is! List || rewards.length > 32 || rewards.any((r) => r is! Map || r['id'] is! String || !['none','scarf','beret','explorer','astronaut','chef','doctor','builder','detective'].contains(r['outfit']))) throw const FormatException('Invalid pack rewards');
  }
}
