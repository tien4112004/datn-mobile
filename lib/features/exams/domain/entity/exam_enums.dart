/// Exam status enumeration.
enum ExamStatus {
  draft,
  generating,
  completed,
  error,
  archived;

  String get displayName {
    switch (this) {
      case ExamStatus.draft:
        return 'Draft';
      case ExamStatus.generating:
        return 'Generating';
      case ExamStatus.completed:
        return 'Completed';
      case ExamStatus.error:
        return 'Error';
      case ExamStatus.archived:
        return 'Archived';
    }
  }

  static ExamStatus fromString(String value) {
    return ExamStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ExamStatus.draft,
    );
  }
}

/// Difficulty level enumeration.
enum Difficulty {
  easy,
  medium,
  hard;

  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  static Difficulty fromString(String value) {
    return Difficulty.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => Difficulty.medium,
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

  static GradeLevel fromString(String value) {
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

/// Question type enumeration.
enum QuestionType {
  multipleChoice,
  trueFalse,
  fillBlank,
  longAnswer,
  matching;

  String get displayName {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.trueFalse:
        return 'True/False';
      case QuestionType.fillBlank:
        return 'Fill in the Blank';
      case QuestionType.longAnswer:
        return 'Long Answer';
      case QuestionType.matching:
        return 'Matching';
    }
  }

  String get apiValue {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'multiple_choice';
      case QuestionType.trueFalse:
        return 'true_false';
      case QuestionType.fillBlank:
        return 'fill_blank';
      case QuestionType.longAnswer:
        return 'long_answer';
      case QuestionType.matching:
        return 'matching';
    }
  }

  static QuestionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'multiple_choice':
        return QuestionType.multipleChoice;
      case 'true_false':
        return QuestionType.trueFalse;
      case 'fill_blank':
        return QuestionType.fillBlank;
      case 'long_answer':
        return QuestionType.longAnswer;
      case 'matching':
        return QuestionType.matching;
      default:
        return QuestionType.multipleChoice;
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

  static ContextType fromString(String value) {
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
