import 'package:datn_mobile/shared/models/cms_enums.dart';

/// Domain entity for creating a question.
class QuestionCreateRequestEntity {
  final String title;
  final QuestionType type;
  final Difficulty difficulty;
  final String? explanation;
  final String? titleImageUrl;
  final Map<String, dynamic> data;
  final GradeLevel? grade;
  final String? chapter;
  final Subject? subject;

  const QuestionCreateRequestEntity({
    required this.title,
    required this.type,
    required this.difficulty,
    this.explanation,
    this.titleImageUrl,
    required this.data,
    this.grade,
    this.chapter,
    this.subject,
  });
}
