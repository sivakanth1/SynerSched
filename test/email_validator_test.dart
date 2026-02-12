import 'package:flutter_test/flutter_test.dart';
import 'package:syner_sched/shared/email_validator.dart';

void main() {
  group('EmailValidator.isEmailValid', () {
    test('should return true for valid email', () {
      expect(EmailValidator.isEmailValid('test@example.com'), isTrue);
    });

    test('should return true for email with dots', () {
      expect(EmailValidator.isEmailValid('test.email@example.com'), isTrue);
    });

    test('should return true for email with subdomains', () {
      expect(EmailValidator.isEmailValid('test@sub.example.com'), isTrue);
    });

    test('should return true for email with special characters', () {
      expect(EmailValidator.isEmailValid('test+label@example.com'), isTrue);
    });

    test('should return true for email with hyphens in domain', () {
      expect(EmailValidator.isEmailValid('test@my-domain.com'), isTrue);
    });

    test('should return false for missing @', () {
      expect(EmailValidator.isEmailValid('testexample.com'), isFalse);
    });

    test('should return false for missing domain', () {
      expect(EmailValidator.isEmailValid('test@'), isFalse);
    });

    test('should return false for missing local part', () {
      expect(EmailValidator.isEmailValid('@example.com'), isFalse);
    });

    test('should return false for empty string', () {
      expect(EmailValidator.isEmailValid(''), isFalse);
    });

    test('should return false for email with trailing characters (potential XSS)', () {
      expect(EmailValidator.isEmailValid('test@example.com<script>alert(1)</script>'), isFalse);
    });

    test('should return false for email with spaces', () {
      expect(EmailValidator.isEmailValid('test @example.com'), isFalse);
    });

    test('should return false for email with comma', () {
      expect(EmailValidator.isEmailValid('test,user@example.com'), isFalse);
    });

    test('should return false for email with double @', () {
      expect(EmailValidator.isEmailValid('test@@example.com'), isFalse);
    });
  });
}
