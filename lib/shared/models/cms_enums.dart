import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum QuestionType {
  multipleChoice(),
  matching(),
  openEnded(),
  fillInBlank();

  String get displayName {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.matching:
        return 'Matching';
      case QuestionType.openEnded:
        return 'Open Ended';
      case QuestionType.fillInBlank:
        return 'Fill in Blank';
    }
  }

  static QuestionType fromApiValue(String questionType) {
    switch (questionType.toUpperCase()) {
      case 'MULTIPLE_CHOICE':
        return QuestionType.multipleChoice;
      case 'MATCHING':
        return QuestionType.matching;
      case 'OPEN_ENDED':
        return QuestionType.openEnded;
      case 'FILL_IN_BLANK':
        return QuestionType.fillInBlank;
      default:
        return QuestionType.multipleChoice;
    }
  }

  String get apiValue {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'MULTIPLE_CHOICE';
      case QuestionType.matching:
        return 'MATCHING';
      case QuestionType.openEnded:
        return 'OPEN_ENDED';
      case QuestionType.fillInBlank:
        return 'FILL_IN_BLANK';
    }
  }

  static Color getColor(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return Colors.green;
      case QuestionType.matching:
        return Colors.orange;
      case QuestionType.openEnded:
        return Colors.red;
      case QuestionType.fillInBlank:
        return Colors.blue;
    }
  }

  static IconData getIcon(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return LucideIcons.circleCheck;
      case QuestionType.matching:
        return LucideIcons.gitCompareArrows;
      case QuestionType.openEnded:
        return LucideIcons.pencil;
      case QuestionType.fillInBlank:
        return LucideIcons.form;
    }
  }
}

enum Difficulty {
  easy,
  medium,
  hard,
  knowledge,
  comprehension,
  application,
  advancedApplication;

  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.knowledge:
        return 'Knowledge';
      case Difficulty.comprehension:
        return 'Comprehension';
      case Difficulty.application:
        return 'Application';
      case Difficulty.advancedApplication:
        return 'Advanced Application';
    }
  }

  String get apiValue {
    switch (this) {
      case Difficulty.easy:
        return 'EASY';
      case Difficulty.medium:
        return 'MEDIUM';
      case Difficulty.hard:
        return 'HARD';
      case Difficulty.knowledge:
        return 'KNOWLEDGE';
      case Difficulty.comprehension:
        return 'COMPREHENSION';
      case Difficulty.application:
        return 'APPLICATION';
      case Difficulty.advancedApplication:
        return 'ADVANCED_APPLICATION';
    }
  }

  static Difficulty fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'EASY':
        return Difficulty.easy;
      case 'MEDIUM':
        return Difficulty.medium;
      case 'HARD':
        return Difficulty.hard;
      case 'KNOWLEDGE':
        return Difficulty.knowledge;
      case 'COMPREHENSION':
        return Difficulty.comprehension;
      case 'APPLICATION':
        return Difficulty.application;
      case 'ADVANCED_APPLICATION':
        return Difficulty.advancedApplication;
      default:
        return Difficulty.knowledge;
    }
  }

  static IconData getDifficultyIcon(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return LucideIcons.trendingDown;
      case Difficulty.medium:
        return LucideIcons.minus;
      case Difficulty.hard:
        return LucideIcons.trendingUp;
      case Difficulty.knowledge:
        return LucideIcons.book;
      case Difficulty.comprehension:
        return LucideIcons.book;
      case Difficulty.application:
        return LucideIcons.book;
      case Difficulty.advancedApplication:
        return LucideIcons.book;
    }
  }

  static Color getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
      case Difficulty.knowledge:
        return Colors.blue;
      case Difficulty.comprehension:
        return Colors.blue;
      case Difficulty.application:
        return Colors.blue;
      case Difficulty.advancedApplication:
        return Colors.blue;
    }
  }

  static Difficulty fromName(String name) {
    switch (name.toUpperCase()) {
      case 'EASY':
        return Difficulty.easy;
      case 'MEDIUM':
        return Difficulty.medium;
      case 'HARD':
        return Difficulty.hard;
      case 'KNOWLEDGE':
        return Difficulty.knowledge;
      case 'COMPREHENSION':
        return Difficulty.comprehension;
      case 'APPLICATION':
        return Difficulty.application;
      case 'ADVANCED_APPLICATION':
        return Difficulty.advancedApplication;
      default:
        return Difficulty.knowledge;
    }
  }
}

enum QuestionMode {
  editing,
  doing,
  viewing,
  grading,
  afterAssess;

  String get displayName {
    switch (this) {
      case QuestionMode.editing:
        return 'Editing Mode';
      case QuestionMode.doing:
        return 'Doing Mode';
      case QuestionMode.viewing:
        return 'Viewing Mode';
      case QuestionMode.grading:
        return 'Grading Mode';
      case QuestionMode.afterAssess:
        return 'After Assessment Mode';
    }
  }
}

enum BankType {
  personal,
  public;

  String get displayName {
    switch (this) {
      case BankType.personal:
        return 'Personal';
      case BankType.public:
        return 'Public';
    }
  }
}

/// Grade levels for questions (1-5)
enum GradeLevel {
  grade1,
  grade2,
  grade3,
  grade4,
  grade5;

  String get displayName {
    switch (this) {
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

  static GradeLevel fromApiValue(String value) {
    switch (value.toUpperCase()) {
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
        return GradeLevel.grade1;
    }
  }
}

/// Subject categories for questions
enum Subject {
  english,
  mathematics,
  literature;

  String get displayName {
    switch (this) {
      case Subject.english:
        return 'English';
      case Subject.mathematics:
        return 'Mathematics';
      case Subject.literature:
        return 'Literature';
    }
  }

  String get apiValue {
    switch (this) {
      case Subject.english:
        return 'TA';
      case Subject.mathematics:
        return 'T';
      case Subject.literature:
        return 'V';
    }
  }

  static Subject fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'ENGLISH':
        return Subject.english;
      case 'MATHEMATICS':
        return Subject.mathematics;
      case 'LITERATURE':
        return Subject.literature;
      default:
        return Subject.english;
    }
  }
}

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

  static AssignmentStatus fromApiValue(String value) {
    return AssignmentStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => AssignmentStatus.draft,
    );
  }

  static IconData getStatusIcon(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.draft:
        return LucideIcons.file;
      case AssignmentStatus.generating:
        return LucideIcons.loader;
      case AssignmentStatus.completed:
        return LucideIcons.circleCheck;
      case AssignmentStatus.error:
        return LucideIcons.circleX;
      case AssignmentStatus.archived:
        return LucideIcons.archive;
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

  static ContextType fromApiValue(String value) {
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
