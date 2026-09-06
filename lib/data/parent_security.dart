import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// PBKDF2-HMAC-SHA256, one block (32 bytes), off the UI isolate.
String derivePin(List<String> args) {
  final hmac = Hmac(sha256, utf8.encode(args[0]));
  var u = hmac.convert([...base64Decode(args[1]), 0, 0, 0, 1]).bytes;
  final result = List<int>.from(u);
  for (var i = 1; i < 120000; i++) {
    u = hmac.convert(u).bytes;
    for (var j = 0; j < 32; j++) {
      result[j] ^= u[j];
    }
  }
  return base64Encode(result);
}

class ParentSecurity {
  final FlutterSecureStorage storage;
  ParentSecurity({this.storage = const FlutterSecureStorage()});
  Future<bool> hasPin() async => await storage.read(key: 'parent.pin') != null;
  Future<void> setPin(String pin) async {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      throw const FormatException('Choose six digits.');
    }
    final random = Random.secure();
    final salt = base64Encode(List.generate(24, (_) => random.nextInt(256)));
    final hash = await compute(derivePin, [pin, salt]);
    await storage.write(
      key: 'parent.pin',
      value: jsonEncode({'salt': salt, 'hash': hash}),
    );
    await storage.delete(key: 'parent.attempts');
  }

  Future<bool> verify(String pin) async {
    final attempts = jsonDecode(
      await storage.read(key: 'parent.attempts') ?? '{"count":0,"until":0}',
    );
    if (DateTime.now().millisecondsSinceEpoch < (attempts['until'] as int)) {
      throw StateError('Please wait a minute before trying again.');
    }
    final raw = await storage.read(key: 'parent.pin');
    if (raw == null) return false;
    final record = jsonDecode(raw);
    final actual = base64Decode(
      await compute<List<String>, String>(derivePin, [
        pin,
        record['salt'] as String,
      ]),
    );
    final expected = base64Decode(record['hash']);
    var difference = actual.length ^ expected.length;
    for (var i = 0; i < actual.length && i < expected.length; i++) {
      difference |= actual[i] ^ expected[i];
    }
    if (difference == 0) {
      await storage.delete(key: 'parent.attempts');
      return true;
    }
    final count = (attempts['count'] as int) + 1;
    await storage.write(
      key: 'parent.attempts',
      value: jsonEncode({
        'count': count % 5,
        'until': count >= 5
            ? DateTime.now()
                  .add(const Duration(minutes: 1))
                  .millisecondsSinceEpoch
            : 0,
      }),
    );
    return false;
  }
}
