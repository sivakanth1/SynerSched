class CollabValidator {
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxTagLength = 30;
  static const int maxTagsCount = 10;

  static String? validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'title_empty';
    }
    if (title.length > maxTitleLength) {
      return 'title_too_long';
    }
    return null;
  }

  static String? validateDescription(String? desc) {
    if (desc == null || desc.trim().isEmpty) {
      return 'description_empty';
    }
    if (desc.length > maxDescriptionLength) {
      return 'description_too_long';
    }
    return null;
  }

  static String? validateTag(String? tag) {
    if (tag == null || tag.trim().isEmpty) {
      return 'tag_empty';
    }
    if (tag.length > maxTagLength) {
      return 'tag_too_long';
    }
    return null;
  }

  static String? validateTagsCount(List<String> tags) {
    if (tags.length >= maxTagsCount) {
      return 'too_many_tags';
    }
    return null;
  }
}
