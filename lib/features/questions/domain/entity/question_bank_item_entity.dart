import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';

/// Entity representing a question in the question bank with API metadata.
class QuestionBankItemEntity {
  final String id;
  final BaseQuestion question;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuestionBankItemEntity({
    required this.id,
    required this.question,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  QuestionBankItemEntity copyWith({
    String? id,
    BaseQuestion? question,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuestionBankItemEntity(
      id: id ?? this.id,
      question: question ?? this.question,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
