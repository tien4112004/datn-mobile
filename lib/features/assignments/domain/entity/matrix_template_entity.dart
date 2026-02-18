import 'package:AIPrimary/features/assignments/domain/entity/api_matrix_entity.dart';

/// Domain entity for a matrix template.
/// Pure business object without JSON annotations.
///
/// A matrix template represents a pre-configured assignment matrix structure
/// that can be imported into new assignments to save time and maintain consistency.
class MatrixTemplateEntity {
  /// Unique template identifier
  final String id;

  /// Owner user ID (null = public template available to all users)
  final String? ownerId;

  /// Template name for display and search
  final String name;

  /// Subject code (e.g., 'T' for Math, 'TV' for Vietnamese)
  final String subject;

  /// Grade level (e.g., '1', '2', '3')
  final String grade;

  /// Creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Full 3D matrix structure with dimensions and cell values
  final ApiMatrixEntity matrix;

  /// Total number of questions across all matrix cells
  final int totalQuestions;

  /// Total number of topics in the matrix
  final int totalTopics;

  const MatrixTemplateEntity({
    required this.id,
    this.ownerId,
    required this.name,
    required this.subject,
    required this.grade,
    this.createdAt,
    this.updatedAt,
    required this.matrix,
    required this.totalQuestions,
    required this.totalTopics,
  });

  /// Check if this is a public template (available to all users)
  bool get isPublic => ownerId == null;

  /// Check if this is a personal template (owned by specific user)
  bool get isPersonal => !isPublic;

  /// Check if template is compatible with assignment's grade and subject.
  ///
  /// Returns false if:
  /// - Assignment has a grade and template grade doesn't match
  /// - Assignment has a subject and template subject doesn't match
  ///
  /// Returns true if both match or assignment has no grade/subject set.
  bool isCompatibleWith({String? assignmentGrade, String? assignmentSubject}) {
    if (assignmentGrade != null && grade != assignmentGrade) {
      return false;
    }
    if (assignmentSubject != null && subject != assignmentSubject) {
      return false;
    }
    return true;
  }

  @override
  String toString() =>
      'MatrixTemplateEntity(id: $id, name: $name, '
      'subject: $subject, grade: $grade, isPublic: $isPublic)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatrixTemplateEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
