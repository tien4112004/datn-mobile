import 'package:AIPrimary/shared/models/cms_enums.dart';

class GenerateQuestionsRequestEntity {
  final String topic;
  final GradeLevel grade;
  final Subject subject;
  final Map<Difficulty, int> questionsPerDifficulty;
  final List<QuestionType> questionTypes;
  final String? provider;
  final String? model;
  final String? prompt;
  final String? chapter;

  GenerateQuestionsRequestEntity({
    required this.topic,
    required this.grade,
    required this.subject,
    required this.questionsPerDifficulty,
    required this.questionTypes,
    this.provider,
    this.model,
    this.prompt,
    this.chapter,
  });
}
