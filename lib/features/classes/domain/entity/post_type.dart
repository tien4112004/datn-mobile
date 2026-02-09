import 'package:AIPrimary/i18n/strings.g.dart';

enum PostType {
  /// General posts and updates with content, attachments, and linked resources
  post,

  /// Exercise posts for linking assignments
  exercise;

  String getLocalizedName(Translations t) {
    switch (this) {
      case PostType.post:
        return t.classes.postType.post;
      case PostType.exercise:
        return t.classes.postType.exercise;
    }
  }

  /// Converts enum to API string format
  String get apiValue {
    switch (this) {
      case PostType.post:
        return 'post';
      case PostType.exercise:
        return 'exercise';
    }
  }

  /// Returns user-facing display name
  String get displayName {
    switch (this) {
      case PostType.post:
        return 'Post';
      case PostType.exercise:
        return 'Exercise';
    }
  }

  /// Converts API string to PostType enum
  static PostType fromName(String value) {
    switch (value) {
      case 'Post':
      case 'general':
        return PostType.post;
      case 'Exercise':
      case 'exercise':
        return PostType.exercise;
      default:
        return PostType.post;
    }
  }
}
