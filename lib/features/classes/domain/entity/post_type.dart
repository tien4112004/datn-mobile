/// Enum representing different types of posts in a class.
enum PostType {
  /// General posts and updates with content, attachments, and linked resources
  general,

  /// Exercise posts for linking assignments
  exercise;

  /// Converts enum to API string format
  String get apiValue {
    switch (this) {
      case PostType.general:
        return 'general';
      case PostType.exercise:
        return 'exercise';
    }
  }

  /// Returns user-facing display name
  String get displayName {
    switch (this) {
      case PostType.general:
        return 'Post';
      case PostType.exercise:
        return 'Exercise';
    }
  }

  /// Converts API string to PostType enum
  static PostType fromName(String value) {
    switch (value) {
      case 'general':
        return PostType.general;
      case 'exercise':
        return PostType.exercise;
      default:
        return PostType.general;
    }
  }
}
