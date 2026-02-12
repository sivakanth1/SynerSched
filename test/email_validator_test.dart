import 'package:flutter_test/flutter_test.dart';
import 'package:syner_sched/shared/email_validator.dart';

void main() {
  group('EmailValidator.isEmailValid', () {
    test('should return true for valid email', () {
      expect(EmailValidator.isEmailValid('test@example.com'), isTrue);
    });

    test('should return true for email with subdomain', () {
      expect(EmailValidator.isEmailValid('test@sub.example.com'), isTrue);
    });

    test('should return true for email with special characters', () {
      expect(EmailValidator.isEmailValid('test.email+regex@example.com'), isTrue);
    });

    test('should return false for email without @', () {
      expect(EmailValidator.isEmailValid('testexample.com'), isFalse);
    });

    test('should return false for email without domain', () {
      expect(EmailValidator.isEmailValid('test@'), isFalse);
    });

    test('should return false for email without username', () {
      expect(EmailValidator.isEmailValid('@example.com'), isFalse);
    });

    test('should return false for empty email', () {
      expect(EmailValidator.isEmailValid(''), isFalse);
    });

    test('should return false for email with spaces', () {
      expect(EmailValidator.isEmailValid('test @example.com'), isFalse);
    });

    test('should return false for email without top level domain', () {
      expect(EmailValidator.isEmailValid('test@example'), isFalse);
    });
  });
}
