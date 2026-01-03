enum QuestionType {
  multipleChoice,
  matching,
  openEnded,
  fillInBlank;

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
}

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
