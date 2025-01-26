import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  static final _key = encrypt.Key.fromUtf8(
    '16charSecretKey!!',
  ); // Must be exactly 16 chars
  static final _iv = encrypt.IV.fromLength(16); // Initialization vector

  static String encryptPassword(String password) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(password, iv: _iv);
    return encrypted.base64;
  }

  static String decryptPassword(String encrypted) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final decrypted = encrypter.decrypt64(encrypted, iv: _iv);
    return decrypted;
  }
}
