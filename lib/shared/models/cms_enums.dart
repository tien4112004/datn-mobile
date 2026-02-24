import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum QuestionType {
  multipleChoice(),
  matching(),
  openEnded(),
  fillInBlank();

  String getLocalizedName(Translations t) {
    switch (this) {
      case QuestionType.multipleChoice:
        return t.questionBank.questionTypes.multipleChoice;
      case QuestionType.matching:
        return t.questionBank.questionTypes.matching;
      case QuestionType.openEnded:
        return t.questionBank.questionTypes.openEnded;
      case QuestionType.fillInBlank:
        return t.questionBank.questionTypes.fillInBlank;
    }
  }

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
  knowledge,
  comprehension,
  application,
  advancedApplication;

  String getLocalizedName(Translations t) {
    switch (this) {
      case Difficulty.knowledge:
        return t.questionBank.difficulties.knowledge;
      case Difficulty.comprehension:
        return t.questionBank.difficulties.comprehension;
      case Difficulty.application:
        return t.questionBank.difficulties.application;
      case Difficulty.advancedApplication:
        return 'Advanced Application';
    }
  }

  String get displayName {
    switch (this) {
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
      case Difficulty.knowledge:
        return LucideIcons.book;
      case Difficulty.comprehension:
        return LucideIcons.book;
      case Difficulty.application:
        return LucideIcons.book;
      case Difficulty.advancedApplication:
        return LucideIcons.bookOpen;
    }
  }

  static Color getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.knowledge:
        return Colors.green;
      case Difficulty.comprehension:
        return Colors.blue;
      case Difficulty.application:
        return Colors.orange;
      case Difficulty.advancedApplication:
        return Colors.red;
    }
  }

  static Difficulty fromName(String name) {
    switch (name.toUpperCase()) {
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
  submitted,
  grading,
  afterAssess;

  String getLocalizedName(Translations t) {
    switch (this) {
      case QuestionMode.editing:
        return t
            .shared
            .models
            .cms_enums
            .questionMode
            .editing; // Note: Need to add these to JSON
      case QuestionMode.doing:
        return t.shared.models.cms_enums.questionMode.doing;
      case QuestionMode.viewing:
        return t.questionBank.viewing.viewingMode;
      case QuestionMode.submitted:
        return t.assignments.statuses.completed;
      case QuestionMode.grading:
        return t.questionBank.viewing.grading;
      case QuestionMode.afterAssess:
        return t.shared.models.cms_enums.questionMode.afterAssess;
    }
  }

  String get displayName {
    switch (this) {
      case QuestionMode.editing:
        return 'Editing Mode';
      case QuestionMode.doing:
        return 'Doing Mode';
      case QuestionMode.viewing:
        return 'Viewing Mode';
      case QuestionMode.submitted:
        return 'Submitted';
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

  String getLocalizedName(Translations t) {
    switch (this) {
      case BankType.personal:
        return t.questionBank.bankTypes.myQuestions;
      case BankType.public:
        return t.questionBank.bankTypes.publicBank;
    }
  }

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

  String getLocalizedName(Translations t) {
    switch (this) {
      case GradeLevel.grade1:
        return t.questionBank.grades.grade1;
      case GradeLevel.grade2:
        return t.questionBank.grades.grade2;
      case GradeLevel.grade3:
        return t.questionBank.grades.grade3;
      case GradeLevel.grade4:
        return t.questionBank.grades.grade4;
      case GradeLevel.grade5:
        return t.questionBank.grades.grade5;
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
  vietnamese;

  String getLocalizedName(Translations t) {
    switch (this) {
      case Subject.english:
        return t.questionBank.subjects.english;
      case Subject.mathematics:
        return t.questionBank.subjects.mathematics;
      case Subject.vietnamese:
        return t.questionBank.subjects.vietnamese;
    }
  }

  String get apiValue {
    switch (this) {
      case Subject.english:
        return 'TA';
      case Subject.mathematics:
        return 'T';
      case Subject.vietnamese:
        return 'TV';
    }
  }

  static Subject fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'TA':
        return Subject.english;
      case 'T':
        return Subject.mathematics;
      case 'TV':
        return Subject.vietnamese;
      case 'ENGLISH':
        return Subject.english;
      case 'MATHEMATICS':
        return Subject.mathematics;
      case 'VIETNAMESE':
        return Subject.vietnamese;
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

  String getLocalizedName(Translations t) {
    switch (this) {
      case AssignmentStatus.draft:
        return t
            .projects
            .untitled; // Using untitled as a proxy or need to add Draft
      case AssignmentStatus.generating:
        return t.generate.customization.generating;
      case AssignmentStatus.completed:
        return t.common.save; // Placeholder
      case AssignmentStatus.error:
        return t.common.error;
      case AssignmentStatus.archived:
        return t.shared.models.cms_enums.assignmentStatus.archived;
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

  String getLocalizedName(Translations t) {
    switch (this) {
      case ContextType.readingPassage:
        return t.shared.models.cms_enums.contextType.readingPassage;
      case ContextType.image:
        return t.projects.resource_types.image;
      case ContextType.audio:
        return t.shared.models.cms_enums.contextType.audio;
      case ContextType.video:
        return t.shared.models.cms_enums.contextType.video;
    }
  }

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
