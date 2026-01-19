import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/ui/widgets/question_card_wrapper.dart';

/// Matching Question in Viewing Mode
class MatchingViewing extends StatelessWidget {
  final MatchingQuestion question;

  const MatchingViewing({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return QuestionCardWrapper(
      title: question.title,
      titleImageUrl: question.titleImageUrl,
      difficulty: question.difficulty,
      type: question.type,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VIEWING MODE - Correct matches:',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...question.data.pairs.map((pair) {
            return _buildPairDisplay(pair, theme);
          }),
        ],
      ),
    );
  }

  Widget _buildPairDisplay(MatchingPair pair, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
        color: Colors.green.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pair.left,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.arrow_forward, color: Colors.green),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pair.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
