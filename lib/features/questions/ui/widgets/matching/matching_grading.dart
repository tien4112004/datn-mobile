import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '_matching_content_widget.dart';

/// Matching Question in Grading Mode (Teacher reviewing student answers)
/// Enhanced with Material 3 design principles
class MatchingGrading extends ConsumerWidget {
  final MatchingQuestion question;
  final Map<String, String>? studentAnswers; // leftItem -> selectedRightItem

  const MatchingGrading({
    super.key,
    required this.question,
    this.studentAnswers,
  });

  int get _correctCount {
    if (studentAnswers == null) return 0;
    int count = 0;
    for (var pair in question.data.pairs) {
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
    final totalPairs = question.data.pairs.length;

    return QuestionCardWrapper(
      title: question.title,
      titleImageUrl: question.titleImageUrl,
      difficulty: question.difficulty,
      type: question.type,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _correctCount == totalPairs
                      ? Colors.green
                      : _correctCount > totalPairs / 2
                      ? Colors.orange
                      : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.assessment, size: 18, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      '$_correctCount/$totalPairs',
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

            return _buildGradingPair(
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

  Widget _buildGradingPair(
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
          // Status badge
          Row(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
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
                      ? Icons.cancel
                      : Icons.help_outline,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Left side (question)
          Text(
            '${t.questionBank.matching.leftSide}:',
            style: theme.textTheme.bodySmall?.copyWith(
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
              '${t.submissions.grading.studentAnswer}:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            MatchingContentWidget(
              text: studentSelectedPair?.right,
              imageUrl: studentSelectedPair?.rightImageUrl,
              backgroundColor: Colors.transparent,
              borderWidth: 2,
            ),
            const SizedBox(height: 16),
          ] else ...[
            Text(
              '${t.submissions.grading.studentAnswer}:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            MatchingContentWidget(
              text: t.submissions.grading.notAnswered,
              backgroundColor: Colors.transparent,
              borderWidth: 2,
            ),
            const SizedBox(height: 16),
          ],
          // Correct answer
          Text(
            '${t.submissions.grading.expectedAnswer}:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          MatchingContentWidget(
            text: pair.right,
            imageUrl: pair.rightImageUrl,
            backgroundColor: Colors.transparent,
            borderWidth: 2,
          ),
        ],
      ),
    );
  }
}
