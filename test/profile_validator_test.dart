import 'package:flutter_test/flutter_test.dart';
import 'package:syner_sched/shared/profile_validator.dart';

void main() {
  group('ProfileValidator', () {
    group('validateName', () {
      test('should return null for valid name', () {
        expect(ProfileValidator.validateName('John Doe'), isNull);
        expect(ProfileValidator.validateName('Mary-Jane'), isNull);
        expect(ProfileValidator.validateName("O'Connor"), isNull);
        expect(ProfileValidator.validateName("José García"), isNull);
        expect(ProfileValidator.validateName("Noël"), isNull);
      });

      test('should return error for empty name', () {
        expect(ProfileValidator.validateName(null), 'invalid_name_length');
        expect(ProfileValidator.validateName(''), 'invalid_name_length');
        expect(ProfileValidator.validateName('   '), 'invalid_name_length');
      });

      test('should return error for name too short', () {
        expect(ProfileValidator.validateName('A'), 'invalid_name_length');
      });

      test('should return error for name too long', () {
        final longName = 'A' * 51;
        expect(ProfileValidator.validateName(longName), 'invalid_name_length');
      });

      test('should return error for invalid characters', () {
        expect(ProfileValidator.validateName('John123'), 'invalid_name_chars');
        expect(ProfileValidator.validateName('John@Doe'), 'invalid_name_chars');
      });
    });

    group('validateYear', () {
      test('should return null for valid year', () {
        expect(ProfileValidator.validateYear('Freshman'), isNull);
        expect(ProfileValidator.validateYear('2024'), isNull);
        expect(ProfileValidator.validateYear('Year 3'), isNull);
        expect(ProfileValidator.validateYear('Año 2'), isNull);
      });

      test('should return error for empty year', () {
        expect(ProfileValidator.validateYear(null), 'invalid_year_length');
        expect(ProfileValidator.validateYear(''), 'invalid_year_length');
        expect(ProfileValidator.validateYear('   '), 'invalid_year_length');
      });

      test('should return error for year too short', () {
        expect(ProfileValidator.validateYear('1'), 'invalid_year_length');
      });

      test('should return error for year too long', () {
        final longYear = 'A' * 21;
        expect(ProfileValidator.validateYear(longYear), 'invalid_year_length');
      });

      test('should return error for invalid characters', () {
        expect(ProfileValidator.validateYear('Year@2024'), 'invalid_year_chars');
      });
    });

    group('validateInterests', () {
      test('should return null for valid interests', () {
        expect(ProfileValidator.validateInterests(['Coding', 'Reading']), isNull);
        expect(ProfileValidator.validateInterests(['Fútbol', 'Música']), isNull);
        expect(ProfileValidator.validateInterests([]), isNull);
        expect(ProfileValidator.validateInterests(null), isNull);
      });

      test('should filter empty strings and pass', () {
        expect(ProfileValidator.validateInterests(['Coding', '', '  ']), isNull);
      });

      test('should return error for too many interests', () {
        final interests = List.generate(11, (index) => 'Interest $index');
        expect(ProfileValidator.validateInterests(interests), 'invalid_interests_count');
      });

      test('should return error for interest too short', () {
        expect(ProfileValidator.validateInterests(['A']), 'invalid_interests_length');
      });

      test('should return error for interest too long', () {
        final longInterest = 'A' * 31;
        expect(ProfileValidator.validateInterests([longInterest]), 'invalid_interests_length');
      });

      test('should return error for invalid characters', () {
        expect(ProfileValidator.validateInterests(['Coding!']), 'invalid_interests_chars');
      });
    });

    group('validateSkills', () {
      test('should return null for valid skills', () {
        expect(ProfileValidator.validateSkills(['Flutter', 'Dart']), isNull);
        expect(ProfileValidator.validateSkills([]), isNull);
        expect(ProfileValidator.validateSkills(null), isNull);
      });

      test('should return error for too many skills', () {
        final skills = List.generate(21, (index) => 'Skill $index');
        expect(ProfileValidator.validateSkills(skills), 'invalid_skills_count');
      });

      test('should return error for skill too long', () {
        final longSkill = 'A' * 31;
        expect(ProfileValidator.validateSkills([longSkill]), 'invalid_skills_length');
      });
    });
  });
}
