import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fill in Blank Question in After Assessment Mode (Student reviewing their answers)
/// Enhanced with Material 3 design principles
class FillInBlankAfterAssess extends ConsumerWidget {
  final FillInBlankQuestion question;
  final Map<String, String>? studentAnswers; // blankId -> answer

  const FillInBlankAfterAssess({
    super.key,
    required this.question,
    this.studentAnswers,
  });

  int get _correctCount {
    if (studentAnswers == null) return 0;
    int count = 0;
    for (var segment in question.data.segments) {
      if (segment.type == SegmentType.blank) {
        final studentAnswer = studentAnswers![segment.id] ?? '';
        if (_isCorrectAnswer(segment, studentAnswer)) {
          count++;
        }
      }
    }
    return count;
  }

  int get _totalBlanks {
    return question.data.segments
        .where((s) => s.type == SegmentType.blank)
        .length;
  }

  bool _isCorrectAnswer(BlankSegment segment, String answer) {
    final caseSensitive = question.data.caseSensitive;
    final correctAnswer = caseSensitive
        ? segment.content
        : segment.content.toLowerCase();
    final studentAnswer = caseSensitive ? answer : answer.toLowerCase();

    if (studentAnswer == correctAnswer) return true;

    if (segment.acceptableAnswers != null) {
      for (var acceptable in segment.acceptableAnswers!) {
        final acceptableFormatted = caseSensitive
            ? acceptable
            : acceptable.toLowerCase();
        if (studentAnswer == acceptableFormatted) return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percentage = _totalBlanks > 0
        ? (_correctCount / _totalBlanks * 100).round()
        : 0;

    return QuestionCardWrapper(
      title: question.title,
      titleImageUrl: question.titleImageUrl,
      difficulty: question.difficulty,
      type: question.type,
      explanation: question.explanation,
      showExplanation: true,
      showBadges: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: question.data.segments.map((segment) {
              if (segment.type == SegmentType.text) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    segment.content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                );
              } else {
                final studentAnswer = studentAnswers?[segment.id] ?? '';
                final isCorrect = _isCorrectAnswer(segment, studentAnswer);
                final isAnswered = studentAnswer.isNotEmpty;

                return _buildReviewBlank(
                  segment,
                  studentAnswer,
                  isCorrect,
                  isAnswered,
                  theme,
                  t,
                );
              }
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewBlank(
    BlankSegment segment,
    String studentAnswer,
    bool isCorrect,
    bool isAnswered,
    ThemeData theme,
    Translations t,
  ) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student answer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green.shade50
                  : isAnswered
                  ? Colors.red.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCorrect
                    ? Colors.green
                    : isAnswered
                    ? Colors.red
                    : Colors.orange,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCorrect
                      ? Icons.check_circle
                      : isAnswered
                      ? Icons.cancel
                      : Icons.remove_circle_outline,
                  size: 16,
                  color: isCorrect
                      ? Colors.green.shade700
                      : isAnswered
                      ? Colors.red.shade700
                      : Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    studentAnswer.isEmpty
                        ? t.questionBank.matching.required
                        : studentAnswer, // Reuse matching.required or add specific
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isCorrect
                          ? Colors.green.shade900
                          : isAnswered
                          ? Colors.red.shade900
                          : Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Correct answer (shown if incorrect)
          if (!isCorrect) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.shade300, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 14, color: Colors.green.shade700),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      segment.content,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade900,
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
}
