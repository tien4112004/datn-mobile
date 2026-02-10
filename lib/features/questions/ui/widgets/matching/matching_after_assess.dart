import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '_matching_content_widget.dart';

/// Matching Question in After Assessment Mode (Student reviewing their answers)
/// Enhanced with Material 3 design principles
class MatchingAfterAssess extends ConsumerWidget {
  final MatchingQuestion question;
  final Map<String, String>? studentAnswers; // leftItem -> selectedRightItem

  const MatchingAfterAssess({
    super.key,
    required this.question,
    this.studentAnswers,
  });

  int get _correctCount {
    if (studentAnswers == null) return 0;
    int count = 0;
    for (var pair in question.data.pairs) {
      // Match by pair ID instead of text content
      final studentSelectedId = studentAnswers![pair.id];
      if (studentSelectedId == pair.id) {
        count++;
      }
    }
    return count;
  }

  MatchingPair? _findPairById(String id) {
    try {
      return question.data.pairs.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalPairs = question.data.pairs.length;
    final percentage = totalPairs > 0
        ? (_correctCount / totalPairs * 100).round()
        : 0;

    return QuestionCardWrapper(
      title: question.title,
      titleImageUrl: question.titleImageUrl,
      difficulty: question.difficulty,
      type: question.type,
      explanation: question.explanation,
      showExplanation: true,
      showHeader: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.questionBank.viewing.viewingMode,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: percentage >= 80
                      ? Colors.green
                      : percentage >= 60
                      ? Colors.orange
                      : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      percentage >= 80
                          ? Icons.emoji_events
                          : percentage >= 60
                          ? Icons.thumb_up
                          : Icons.error_outline,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$percentage% ($_correctCount/$totalPairs)',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...question.data.pairs.map((pair) {
            final studentSelectedId = studentAnswers?[pair.id];
            final studentSelectedPair = studentSelectedId != null
                ? _findPairById(studentSelectedId)
                : null;
            final isCorrect = studentSelectedId == pair.id;
            final isAnswered = studentSelectedId != null;

            return _buildReviewPair(
              pair,
              studentSelectedPair,
              isCorrect,
              isAnswered,
              theme,
              t,
            );
          }),
          if (studentAnswers == null || studentAnswers!.isEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.questionBank.multipleChoice.notAnswered,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewPair(
    MatchingPair pair,
    MatchingPair? studentSelectedPair,
    bool isCorrect,
    bool isAnswered,
    ThemeData theme,
    Translations t,
  ) {
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.shade50
            : isAnswered
            ? Colors.red.shade50
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect
              ? Colors.green
              : isAnswered
              ? Colors.red
              : colorScheme.outlineVariant,
          width: (isCorrect || isAnswered) ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCorrect
                      ? Colors.green
                      : isAnswered
                      ? Colors.red
                      : colorScheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect
                      ? Icons.check
                      : isAnswered
                      ? Icons.close
                      : Icons.remove,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isCorrect
                      ? t.questionBank.viewing.correct
                      : isAnswered
                      ? t.questionBank.matching.incorrect
                      : t.questionBank.matching.notAnswered,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCorrect
                        ? Colors.green.shade700
                        : isAnswered
                        ? Colors.red.shade700
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Left side (question)
          Text(
            '${t.questionBank.matching.leftSide}:',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          MatchingContentWidget(
            text: pair.left,
            imageUrl: pair.leftImageUrl,
            backgroundColor: theme.colorScheme.surface,
            borderColor: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          // Student's answer
          if (isAnswered) ...[
            Text(
              '${t.questionBank.openEnded.gradingNote}:',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            MatchingContentWidget(
              text: studentSelectedPair?.right,
              imageUrl: studentSelectedPair?.rightImageUrl,
              backgroundColor: isCorrect
                  ? Colors.green.shade100
                  : Colors.red.shade100,
              borderColor: isCorrect
                  ? Colors.green.shade300
                  : Colors.red.shade300,
              borderWidth: 2,
            ),
            const SizedBox(height: 16),
          ],
          // Correct answer
          if (!isCorrect) ...[
            Text(
              '${t.questionBank.viewing.correct}:',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            MatchingContentWidget(
              text: pair.right,
              imageUrl: pair.rightImageUrl,
              backgroundColor: Colors.green.shade100,
              borderColor: Colors.green.shade300,
              borderWidth: 2,
            ),
          ],
        ],
      ),
    );
  }
}
