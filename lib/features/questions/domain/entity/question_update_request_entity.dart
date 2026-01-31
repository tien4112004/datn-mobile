import 'package:AIPrimary/shared/models/cms_enums.dart';

/// Domain entity for updating a question.
/// All fields are optional, only provide what needs updating.
class QuestionUpdateRequestEntity {
  final String? title;
  final QuestionType? type;
  final Difficulty? difficulty;
  final String? explanation;
  final String? titleImageUrl;
  final Map<String, dynamic>? data;
  final GradeLevel? grade;
  final String? chapter;
  final Subject? subject;

  const QuestionUpdateRequestEntity({
    this.title,
    this.type,
    this.difficulty,
    this.explanation,
    this.titleImageUrl,
    this.data,
    this.grade,
    this.chapter,
    this.subject,
  });
}
