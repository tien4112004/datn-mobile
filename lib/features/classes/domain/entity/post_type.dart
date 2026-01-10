/// Enum representing different types of posts in a class.
enum PostType {
  /// Important announcements from teachers
  announcement,

  /// Scheduled events or deadlines
  scheduleEvent,

  /// General posts and updates
  general;

  /// Converts enum to API string format
  String get apiValue {
    switch (this) {
      case PostType.announcement:
        return 'announcement';
      case PostType.scheduleEvent:
        return 'schedule_event';
      case PostType.general:
        return 'general';
    }
  }

  /// Returns user-facing display name
  String get displayName {
    switch (this) {
      case PostType.announcement:
        return 'Announcement';
      case PostType.scheduleEvent:
        return 'Event';
      case PostType.general:
        return 'Post';
    }
  }

  /// Converts API string to PostType enum
  static PostType fromName(String value) {
    switch (value) {
      case 'announcement':
        return PostType.announcement;
      case 'schedule_event':
        return PostType.scheduleEvent;
      case 'general':
        return PostType.general;
      default:
        return PostType.general;
    }
  }
}
