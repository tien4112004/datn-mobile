import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';

/// Domain entity for updating a question.
/// All fields are optional, only provide what needs updating.
class QuestionUpdateRequestEntity {
  final String? title;
  final QuestionType? type;
  final Difficulty? difficulty;
  final String? explanation;
  final String? titleImageUrl;
  final int? points;
  final Map<String, dynamic>? data;

  const QuestionUpdateRequestEntity({
    this.title,
    this.type,
    this.difficulty,
    this.explanation,
    this.titleImageUrl,
    this.points,
    this.data,
  });
}
