enum NotificationType {
  post,
  assignment,
  comment,
  grade,
  announcement,
  reminder,
  system;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => NotificationType.system,
    );
  }

  String toApiValue() => name.toUpperCase();
}
