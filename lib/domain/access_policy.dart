import 'models.dart';
import '../data/parent_backend.dart';

class AccessPolicy {
  final bool playtest;
  Entitlement? entitlement;
  AccessPolicy({required this.playtest, this.entitlement});
  bool get premium => playtest || (entitlement?.validAt(DateTime.now()) ?? false);
  bool allows(String kind, Json item) {
    if (premium) return true;
    if (!['drawings', 'puzzles', 'stories'].contains(kind)) return false;
    return item['access'] == 'sample';
  }
  bool route(String path, Json? Function(String, String) find) {
    if (premium) return true;
    final parts = path.split('/').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return true;
    if (['cooking', 'roleplay', 'science'].contains(parts.first)) return false;
    final kind = {'drawing': 'drawings', 'puzzle': 'puzzles', 'story': 'stories'}[parts.first];
    if (kind != null && parts.length > 1) {
      final d = find(kind, parts[1]);
      return d != null && allows(kind, d);
    }
    return true;
  }
}
