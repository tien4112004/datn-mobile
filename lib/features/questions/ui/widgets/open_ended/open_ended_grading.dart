import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Open Ended Question in Grading Mode
class OpenEndedGrading extends ConsumerStatefulWidget {
  final OpenEndedQuestion question;
  final String? studentAnswer;
  final int? score;
  final Function(int)? onScoreChanged;

  const OpenEndedGrading({
    super.key,
    required this.question,
    this.studentAnswer,
    this.score,
    this.onScoreChanged,
  });

  @override
  ConsumerState<OpenEndedGrading> createState() => _OpenEndedGradingState();
}

class _OpenEndedGradingState extends ConsumerState<OpenEndedGrading> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);

    return QuestionCardWrapper(
      title: widget.question.title,
      titleImageUrl: widget.question.titleImageUrl,
      difficulty: widget.question.difficulty,
      type: widget.question.type,
      showBadges: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student's Answer
          Text(
            '${t.submissions.grading.studentAnswer}:', // Reuse or add specific "Student's Answer"
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            width: double.infinity,
            child: Text(
              widget.studentAnswer ?? t.questionBank.matching.required,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: widget.studentAnswer == null
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),

          // Expected Answer (if available)
          if (widget.question.data.expectedAnswer != null) ...[
            const SizedBox(height: 16),
            Text(
              '${t.submissions.grading.expectedAnswer}:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.green[50],
              ),
              width: double.infinity,
              child: Text(
                widget.question.data.expectedAnswer!,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Score Selection
          Text(
            '${t.questionBank.viewing.grading}:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
