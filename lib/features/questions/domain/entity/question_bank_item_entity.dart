import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/shared/models/cms_enums.dart';

/// Entity representing a question in the question bank with API metadata.
class QuestionBankItemEntity {
  final String id;
  final BaseQuestion question;
  final String? ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GradeLevel? grade;
  final String? chapter;
  final Subject? subject;

  const QuestionBankItemEntity({
    required this.id,
    required this.question,
    this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.grade,
    this.chapter,
    this.subject,
  });

  QuestionBankItemEntity copyWith({
    String? id,
    BaseQuestion? question,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    GradeLevel? grade,
    String? chapter,
    Subject? subject,
  }) {
    return QuestionBankItemEntity(
      id: id ?? this.id,
      question: question ?? this.question,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      grade: grade ?? this.grade,
      chapter: chapter ?? this.chapter,
      subject: subject ?? this.subject,
    );
  }
}
