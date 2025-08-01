import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class EncryptionHelper {
  static final IV _fixedIV = IV.fromUtf8('1234567890123456'); // 16-char fixed IV

  static Encrypter getEncrypter(String uid) {
    final keyBytes = sha256.convert(utf8.encode(uid)).bytes;
    final key = Key(Uint8List.fromList(keyBytes));
    return Encrypter(AES(key));
  }

  static String encryptText(String plainText, String uid) {
    final encrypter = getEncrypter(uid);
    return encrypter.encrypt(plainText, iv: _fixedIV).base64;
  }

  static String decryptText(String encryptedText, String uid) {
    try {
      final base64Regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
      if (encryptedText.isEmpty || !base64Regex.hasMatch(encryptedText) || encryptedText.length < 24) {
        throw const FormatException("Invalid encrypted string");
      }

      final encrypter = getEncrypter(uid);
      return encrypter.decrypt64(encryptedText, iv: _fixedIV);
    } catch (e) {
      print("Error: $e");
      return "[Decryption Failed]";
    }
  }
}