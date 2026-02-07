import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';

/// Fill in Blank Question in Submitted Mode
/// Shows filled blanks read-only with neutral styling.
/// No correct/incorrect feedback, no explanation.
class FillInBlankSubmitted extends StatelessWidget {
  final FillInBlankQuestion question;
  final Map<String, String>? studentAnswers;
  final bool showHeader;

  const FillInBlankSubmitted({
    super.key,
    required this.question,
    this.studentAnswers,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final answers = studentAnswers ?? {};
    final blankSegments = question.data.segments
        .where((s) => s.type == SegmentType.blank)
        .toList();
    final answeredCount = blankSegments
        .where((s) => answers[s.id]?.isNotEmpty == true)
        .length;

    return QuestionCardWrapper(
      title: question.title,
      titleImageUrl: question.titleImageUrl,
      difficulty: question.difficulty,
      type: question.type,
      showHeader: showHeader,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Submitted ($answeredCount/${blankSegments.length} filled)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSegments(theme, colorScheme, answers),
        ],
      ),
    );
  }

  Widget _buildSegments(
    ThemeData theme,
    ColorScheme colorScheme,
    Map<String, String> answers,
  ) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 8,
      children: question.data.segments.map((segment) {
        if (segment.type == SegmentType.text) {
          return Text(
            segment.content,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
          );
        }

        // Blank segment — show answer in a styled inline box
        final answer = answers[segment.id] ?? '';
        final hasAnswer = answer.isNotEmpty;

        return Container(
          constraints: const BoxConstraints(minWidth: 80),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: hasAnswer
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasAnswer
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: hasAnswer ? 1.5 : 1,
            ),
          ),
          child: Text(
            hasAnswer ? answer : '(blank)',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: hasAnswer
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              fontStyle: hasAnswer ? FontStyle.normal : FontStyle.italic,
              fontWeight: hasAnswer ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }
}
