import 'package:datn_mobile/features/assignments/domain/entity/assignment_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'question_order_dto.g.dart';

/// DTO for question order structure.
@JsonSerializable()
class QuestionOrderDto {
  final List<Map<String, dynamic>> items;

  QuestionOrderDto({required this.items});

  factory QuestionOrderDto.fromJson(Map<String, dynamic> json) =>
      _$QuestionOrderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionOrderDtoToJson(this);
}

/// Extension for mapping DTO to domain entity.
extension QuestionOrderMapper on QuestionOrderDto {
  QuestionOrder toEntity() {
    final List<QuestionOrderItemBase> parsedItems = items.map((item) {
      final type = item['type'] as String;
      if (type == 'question') {
        return QuestionOrderItem(
          questionId: item['question_id'] as String,
          points: item['points'] as int,
        );
      } else if (type == 'context_group') {
        final questionsData = item['questions'] as List<dynamic>;
        final questions = questionsData
            .map(
              (q) => ContextQuestion(
                questionId: q['question_id'] as String,
                points: q['points'] as int,
              ),
            )
            .toList();
        return ContextGroupOrderItem(
          contextId: item['context_id'] as String,
          questions: questions,
        );
      }
      throw Exception('Unknown question order item type: $type');
    }).toList();

    return QuestionOrder(items: parsedItems);
  }

  static QuestionOrderDto fromEntity(QuestionOrder order) {
    final items = order.items.map((item) {
      if (item is QuestionOrderItem) {
        return {
          'type': 'question',
          'question_id': item.questionId,
          'points': item.points,
        };
      } else if (item is ContextGroupOrderItem) {
        return {
          'type': 'context_group',
          'context_id': item.contextId,
          'questions': item.questions
              .map((q) => {'question_id': q.questionId, 'points': q.points})
              .toList(),
        };
      }
      throw Exception('Unknown question order item type');
    }).toList();

    return QuestionOrderDto(items: items);
  }
}
