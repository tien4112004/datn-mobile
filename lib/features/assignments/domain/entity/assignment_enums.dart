// Re-export Subject enum from question_enums for use in assignments
export 'package:datn_mobile/features/questions/domain/entity/question_enums.dart'
    show Subject;

/// Exam status enumeration.
enum AssignmentStatus {
  draft,
  generating,
  completed,
  error,
  archived;

  String get displayName {
    switch (this) {
      case AssignmentStatus.draft:
        return 'Draft';
      case AssignmentStatus.generating:
        return 'Generating';
      case AssignmentStatus.completed:
        return 'Completed';
      case AssignmentStatus.error:
        return 'Error';
      case AssignmentStatus.archived:
        return 'Archived';
    }
  }

  static AssignmentStatus fromName(String value) {
    return AssignmentStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => AssignmentStatus.draft,
    );
  }
}

/// Grade level enumeration.
enum GradeLevel {
  k,
  grade1,
  grade2,
  grade3,
  grade4,
  grade5;

  String get displayName {
    switch (this) {
      case GradeLevel.k:
        return 'Kindergarten';
      case GradeLevel.grade1:
        return 'Grade 1';
      case GradeLevel.grade2:
        return 'Grade 2';
      case GradeLevel.grade3:
        return 'Grade 3';
      case GradeLevel.grade4:
        return 'Grade 4';
      case GradeLevel.grade5:
        return 'Grade 5';
    }
  }

  String get apiValue {
    switch (this) {
      case GradeLevel.k:
        return 'K';
      case GradeLevel.grade1:
        return '1';
      case GradeLevel.grade2:
        return '2';
      case GradeLevel.grade3:
        return '3';
      case GradeLevel.grade4:
        return '4';
      case GradeLevel.grade5:
        return '5';
    }
  }

  static GradeLevel fromName(String value) {
    switch (value.toUpperCase()) {
      case 'K':
        return GradeLevel.k;
      case '1':
        return GradeLevel.grade1;
      case '2':
        return GradeLevel.grade2;
      case '3':
        return GradeLevel.grade3;
      case '4':
        return GradeLevel.grade4;
      case '5':
        return GradeLevel.grade5;
      default:
        return GradeLevel.k;
    }
  }
}

/// Context type enumeration for questions requiring context.
enum ContextType {
  readingPassage,
  image,
  audio,
  video;

  String get displayName {
    switch (this) {
      case ContextType.readingPassage:
        return 'Reading Passage';
      case ContextType.image:
        return 'Image';
      case ContextType.audio:
        return 'Audio';
      case ContextType.video:
        return 'Video';
    }
  }

  String get apiValue {
    switch (this) {
      case ContextType.readingPassage:
        return 'reading_passage';
      case ContextType.image:
        return 'image';
      case ContextType.audio:
        return 'audio';
      case ContextType.video:
        return 'video';
    }
  }

  static ContextType fromName(String value) {
    switch (value.toLowerCase()) {
      case 'reading_passage':
        return ContextType.readingPassage;
      case 'image':
        return ContextType.image;
      case 'audio':
        return ContextType.audio;
      case 'video':
        return ContextType.video;
      default:
        return ContextType.readingPassage;
    }
  }
}
