import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';

/// Matching Question in Submitted Mode
/// Shows matched pairs read-only with neutral styling.
/// No correct/incorrect feedback, no explanation.
class MatchingSubmitted extends StatelessWidget {
  final MatchingQuestion question;
  final Map<String, String>? studentAnswers;
  final bool showHeader;

  const MatchingSubmitted({
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
    final matchedCount = answers.length;

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
                  'Submitted ($matchedCount/${question.data.pairs.length} matched)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...question.data.pairs.asMap().entries.map((entry) {
            final index = entry.key;
            final pair = entry.value;
            final selectedRightId = answers[pair.id];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPairRow(pair, index, selectedRightId, theme),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPairRow(
    MatchingPair pair,
    int index,
    String? selectedRightId,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;
    final hasMatch = selectedRightId != null;

    // Find the right side text for the matched pair
    String? matchedRightText;
    if (hasMatch) {
      final matchedPair = question.data.pairs
          .where((p) => p.id == selectedRightId)
          .firstOrNull;
      matchedRightText = matchedPair?.right;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasMatch
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasMatch
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outlineVariant,
          width: hasMatch ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Left item
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pair.left ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Arrow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward,
              size: 20,
              color: hasMatch
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          ),
          // Right item
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: hasMatch
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hasMatch ? (matchedRightText ?? '—') : '(not matched)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: hasMatch
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                  fontStyle: hasMatch ? FontStyle.normal : FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
