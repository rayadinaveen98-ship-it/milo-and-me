import 'package:flutter_test/flutter_test.dart';
import 'package:milo_and_me/data/parent_security.dart';

void main() {
  test('PIN derivation matches an independent PBKDF2-SHA256 known answer', () {
    expect(
      derivePin(['123456', 'AAECAwQFBgcICQoLDA0ODxAREhMUFRYX']),
      'WScZ7K0fA5uAmJGlGLNN8LdZFp74Y40LnRcwqS7RsNE=',
    );
  });
}
