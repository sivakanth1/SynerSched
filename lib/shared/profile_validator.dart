/// ProfileValidator
///
/// This class provides validation methods for user profile fields.
/// It enforces constraints on length, character sets, and count limits
/// to ensure data integrity and security.

class ProfileValidator {
  /// Validates the user's name.
  ///
  /// Rules:
  /// - Must be between 2 and 50 characters.
  /// - Must contain only letters, spaces, hyphens, and apostrophes.
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'invalid_name_length';
    }
    final trimmedName = name.trim();
    if (trimmedName.length < 2 || trimmedName.length > 50) {
      return 'invalid_name_length';
    }
    // Allow letters (including international characters), spaces, hyphens, apostrophes.
    if (!RegExp(r"^[\p{L}\s\-']+$", unicode: true).hasMatch(trimmedName)) {
      return 'invalid_name_chars';
    }
    return null;
  }

  /// Validates the academic year.
  ///
  /// Rules:
  /// - Must be between 2 and 20 characters.
  /// - Must contain only alphanumeric characters (including international letters) and spaces.
  static String? validateYear(String? year) {
    if (year == null || year.isEmpty) {
      return 'invalid_year_length';
    }
    final trimmedYear = year.trim();
    if (trimmedYear.length < 2 || trimmedYear.length > 20) {
      return 'invalid_year_length';
    }
    if (!RegExp(r"^[\p{L}\p{N}\s]+$", unicode: true).hasMatch(trimmedYear)) {
      return 'invalid_year_chars';
    }
    return null;
  }

  /// Validates the list of interests.
  ///
  /// Rules:
  /// - Maximum of 10 interests.
  /// - Each interest must be between 2 and 30 characters.
  /// - Each interest must contain only alphanumeric characters (including international letters) and spaces.
  static String? validateInterests(List<String>? interests) {
    if (interests == null) return null; // Or empty list is fine? Assuming optional.

    // Filter out empty strings first (caller should do this, but safe to check)
    final validInterests = interests.where((i) => i.trim().isNotEmpty).toList();

    if (validInterests.length > 10) {
      return 'invalid_interests_count';
    }

    for (final interest in validInterests) {
      final trimmed = interest.trim();
      if (trimmed.length < 2 || trimmed.length > 30) {
        return 'invalid_interests_length';
      }
      if (!RegExp(r"^[\p{L}\p{N}\s]+$", unicode: true).hasMatch(trimmed)) {
        return 'invalid_interests_chars';
      }
    }
    return null;
  }

  /// Validates the list of skills.
  ///
  /// Rules:
  /// - Maximum of 20 skills.
  static String? validateSkills(List<String>? skills) {
    if (skills == null) return null;
    if (skills.length > 20) {
      return 'invalid_skills_count';
    }
    // Skills are selected from a fixed list or added via autocomplete,
    // but we should still validate length if they can type custom ones (which they can in the UI code: _addSkill(controller.text)).
    for (final skill in skills) {
       if (skill.length > 30) {
         return 'invalid_skills_length'; // reusing similar key logic
       }
    }
    return null;
  }
}
