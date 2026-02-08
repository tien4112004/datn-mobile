import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';

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
  final String? contextId;

  const QuestionBankItemEntity({
    required this.id,
    required this.question,
    this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.grade,
    this.chapter,
    this.subject,
    this.contextId,
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
    String? contextId,
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
      contextId: contextId ?? this.contextId,
    );
  }
}
