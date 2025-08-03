/// This file provides helper functions for AES encryption and decryption of text
/// using a user-specific key derived from their UID. It handles the generation of
/// an encryption key, fixed initialization vector (IV), and offers static methods
/// for encrypting and decrypting strings.
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// A helper class to handle AES encryption and decryption of text
/// using a user-specific key derived from their UID.
class EncryptionHelper {
  // A fixed 16-character Initialization Vector used for AES encryption.
  // This IV should remain constant to allow decryption later with the same key.
  static final IV _fixedIV = IV.fromUtf8('1234567890123456');

  /// Generates an Encrypter instance using AES encryption.
  /// The key is derived from the SHA-256 hash of the given user ID.
  static Encrypter getEncrypter(String uid) {
    final keyBytes = sha256.convert(utf8.encode(uid)).bytes;
    final key = Key(Uint8List.fromList(keyBytes));
    return Encrypter(AES(key));
  }

  /// Encrypts a plain text string using AES encryption and the user's UID.
  /// Returns the encrypted result encoded in base64.
  static String encryptText(String plainText, String uid) {
    final encrypter = getEncrypter(uid);
    return encrypter.encrypt(plainText, iv: _fixedIV).base64;
  }

  /// Decrypts a base64-encoded encrypted string using AES and the user's UID.
  /// Returns the original plain text. If decryption fails, returns a fallback string.
  static String decryptText(String encryptedText, String uid) {
    try {
      // Checks if the input string is a valid base64 encoded format
      final base64Regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
      if (encryptedText.isEmpty || !base64Regex.hasMatch(encryptedText) || encryptedText.length < 24) {
        throw const FormatException("Invalid encrypted string");
      }

      final encrypter = getEncrypter(uid);
      return encrypter.decrypt64(encryptedText, iv: _fixedIV);
    } catch (e) {
      // Return a default failure message if decryption fails
      return "[Decryption Failed]";
    }
  }
}