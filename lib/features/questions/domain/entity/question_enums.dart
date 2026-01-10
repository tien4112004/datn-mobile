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

  static QuestionType fromName(String questionType) {
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
        return 'multiple_choice';
      case QuestionType.matching:
        return 'matching';
      case QuestionType.openEnded:
        return 'open_ended';
      case QuestionType.fillInBlank:
        return 'fill_in_blank';
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
