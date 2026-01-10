import 'package:json_annotation/json_annotation.dart';

/// Enum representing user roles in the application
@JsonEnum(valueField: 'value')
enum UserRole {
  student('student'),
  teacher('teacher');

  const UserRole(this.value);

  final String value;

  /// Create UserRole from string value
  static UserRole? fromName(String? value) {
    if (value == null) return null;
    try {
      return UserRole.values.firstWhere((role) => role.value == value);
    } catch (e) {
      return null;
    }
  }

  /// Check if a role string represents a student
  static bool isStudentRole(String? role) {
    return role == UserRole.student.value;
  }

  /// Check if a role string represents a teacher
  static bool isTeacherRole(String? role) {
    return role == UserRole.teacher.value;
  }
}
