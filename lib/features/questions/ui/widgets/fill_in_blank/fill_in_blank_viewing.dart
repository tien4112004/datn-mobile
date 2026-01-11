import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/ui/widgets/question_card_wrapper.dart';

/// Fill in Blank Question in Viewing Mode
class FillInBlankViewing extends StatelessWidget {
  final FillInBlankQuestion question;

  const FillInBlankViewing({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    debugPrint(question.data.segments.toString());

    return QuestionCardWrapper(
      title: question.title,
      titleImageUrl: question.titleImageUrl,
      difficulty: question.difficulty,
      points: question.points ?? 0,
      type: question.type,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VIEWING MODE - Correct answers:',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: question.data.segments.map((segment) {
              if (segment.type == SegmentType.text) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Text(
                    segment.content,
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              } else {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    segment.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.green[900],
                    ),
                  ),
                );
              }
            }).toList(),
          ),
        ],
      ),
    );
  }
}
