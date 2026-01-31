enum NotificationType {
  post,
  assignment,
  comment,
  grade,
  announcement,
  reminder,
  system,
  sharedPresentation,
  sharedMindmap;

  static NotificationType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'POST':
        return NotificationType.post;
      case 'ASSIGNMENT':
        return NotificationType.assignment;
      case 'COMMENT':
        return NotificationType.comment;
      case 'GRADE':
        return NotificationType.grade;
      case 'ANNOUNCEMENT':
        return NotificationType.announcement;
      case 'REMINDER':
        return NotificationType.reminder;
      case 'SYSTEM':
        return NotificationType.system;
      case 'SHARED_PRESENTATION':
        return NotificationType.sharedPresentation;
      case 'SHARED_MINDMAP':
        return NotificationType.sharedMindmap;
      default:
        throw ArgumentError('Unknown NotificationType: $value');
    }
  }

  String toApiValue() => name.toUpperCase();
}
