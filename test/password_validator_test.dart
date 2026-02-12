import 'package:flutter_test/flutter_test.dart';
import 'package:syner_sched/shared/password_validator.dart';

void main() {
  group('PasswordValidator.isPasswordValid', () {
    test('should return true for valid 8-character password', () {
      expect(PasswordValidator.isPasswordValid('Abc1234!'), isTrue);
    });

    test('should return true for valid 16-character password', () {
      expect(PasswordValidator.isPasswordValid('Abc1234!Abc1234!'), isTrue);
    });

    test('should return true for valid 64-character password', () {
      final longPassword = 'A' * 16 + 'a' * 16 + '1' * 16 + '!' * 16;
      expect(PasswordValidator.isPasswordValid(longPassword), isTrue);
    });

    test('should return true for valid 128-character password', () {
      final veryLongPassword = 'A' * 32 + 'a' * 32 + '1' * 32 + '!' * 32;
      expect(PasswordValidator.isPasswordValid(veryLongPassword), isTrue);
    });

    test('should return false for password shorter than 8 characters', () {
      expect(PasswordValidator.isPasswordValid('Abc123!'), isFalse);
    });

    test('should return false for password longer than 128 characters', () {
      final tooLongPassword = 'A' * 33 + 'a' * 32 + '1' * 32 + '!' * 32;
      expect(PasswordValidator.isPasswordValid(tooLongPassword), isFalse);
    });

    test('should return false if missing uppercase', () {
      expect(PasswordValidator.isPasswordValid('abc1234!'), isFalse);
    });

    test('should return false if missing lowercase', () {
      expect(PasswordValidator.isPasswordValid('ABC1234!'), isFalse);
    });

    test('should return false if missing digit', () {
      expect(PasswordValidator.isPasswordValid('Abcdefg!'), isFalse);
    });

    test('should return false if missing special character', () {
      expect(PasswordValidator.isPasswordValid('Abc12345'), isFalse);
    });
  });
}
