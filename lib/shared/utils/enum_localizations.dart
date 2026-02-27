import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';

/// Extension methods to get localized display names for enums
extension QuestionTypeLocalization on QuestionType {
  String localizedName(Translations t) {
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
}

extension DifficultyLocalization on Difficulty {
  String localizedName(Translations t) {
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
}

extension GradeLevelLocalization on GradeLevel {
  String localizedName(Translations t) {
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
}

extension SubjectLocalization on Subject {
  String localizedName(Translations t) {
    switch (this) {
      case Subject.english:
        return t.questionBank.subjects.english;
      case Subject.mathematics:
        return t.questionBank.subjects.mathematics;
      case Subject.vietnamese:
        return t.questionBank.subjects.vietnamese;
    }
  }
}
