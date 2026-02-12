import 'package:flutter_test/flutter_test.dart';
import 'package:syner_sched/features/collab_match/collab_validator.dart';

void main() {
  group('CollabValidator', () {
    test('validateTitle returns error for empty title', () {
      expect(CollabValidator.validateTitle(''), 'title_empty');
      expect(CollabValidator.validateTitle('   '), 'title_empty');
      expect(CollabValidator.validateTitle(null), 'title_empty');
    });

    test('validateTitle returns error for long title', () {
      final longTitle = 'a' * 101;
      expect(CollabValidator.validateTitle(longTitle), 'title_too_long');
    });

    test('validateTitle returns null for valid title', () {
      expect(CollabValidator.validateTitle('Valid Title'), null);
      expect(CollabValidator.validateTitle('a' * 100), null);
    });

    test('validateDescription returns error for empty description', () {
      expect(CollabValidator.validateDescription(''), 'description_empty');
      expect(CollabValidator.validateDescription('   '), 'description_empty');
      expect(CollabValidator.validateDescription(null), 'description_empty');
    });

    test('validateDescription returns error for long description', () {
      final longDesc = 'a' * 501;
      expect(CollabValidator.validateDescription(longDesc), 'description_too_long');
    });

    test('validateDescription returns null for valid description', () {
      expect(CollabValidator.validateDescription('Valid Desc'), null);
      expect(CollabValidator.validateDescription('a' * 500), null);
    });

    test('validateTag returns error for empty tag', () {
      expect(CollabValidator.validateTag(''), 'tag_empty');
      expect(CollabValidator.validateTag('   '), 'tag_empty');
      expect(CollabValidator.validateTag(null), 'tag_empty');
    });

    test('validateTag returns error for long tag', () {
      final longTag = 'a' * 31;
      expect(CollabValidator.validateTag(longTag), 'tag_too_long');
    });

    test('validateTag returns null for valid tag', () {
      expect(CollabValidator.validateTag('Valid Tag'), null);
      expect(CollabValidator.validateTag('a' * 30), null);
    });

    test('validateTagsCount returns error when limit reached (10 or more)', () {
      final tags = List.generate(10, (index) => 'tag$index');
      expect(CollabValidator.validateTagsCount(tags), 'too_many_tags');
    });

    test('validateTagsCount returns null when below limit', () {
      final tags = List.generate(9, (index) => 'tag$index');
      expect(CollabValidator.validateTagsCount(tags), null);
    });
  });
}
