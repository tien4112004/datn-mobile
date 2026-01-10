import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_bank_item_entity.dart';
import 'package:datn_mobile/features/questions/ui/widgets/question_list_card.dart';
import 'package:datn_mobile/shared/widget/animated_list_item.dart';

/// List widget for Question Bank with pull-to-refresh and animations
class QuestionBankList extends StatelessWidget {
  final List<QuestionBankItemEntity> questions;
  final bool isPersonal;
  final bool isLoadingMore;
  final Future<void> Function() onRefresh;
  final void Function(QuestionBankItemEntity) onView;
  final void Function(QuestionBankItemEntity)? onEdit;
  final void Function(QuestionBankItemEntity)? onDelete;

  const QuestionBankList({
    super.key,
    required this.questions,
    required this.isPersonal,
    required this.isLoadingMore,
    required this.onRefresh,
    required this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading more indicator
          if (index == questions.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final item = questions[index];

          // Wrap with AnimatedListItem for smooth entrance animation
          return AnimatedListItem(
            index: index,
            child: QuestionListCard(
              item: item,
              onView: () => onView(item),
              onEdit: isPersonal && onEdit != null ? () => onEdit!(item) : null,
              onDelete: isPersonal && onDelete != null
                  ? () => onDelete!(item)
                  : null,
              showActions: true,
            ),
          );
        },
      ),
    );
  }
}
