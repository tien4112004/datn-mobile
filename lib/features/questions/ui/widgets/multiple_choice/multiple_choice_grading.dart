import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Multiple Choice Question in Grading Mode (Teacher reviewing student answer)
/// Enhanced with Material 3 design principles
class MultipleChoiceGrading extends ConsumerWidget {
  final MultipleChoiceQuestion question;
  final String? studentAnswer;

  const MultipleChoiceGrading({
    super.key,
    required this.question,
    this.studentAnswer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);

    return QuestionCardWrapper(
      title: question.title,
      titleImageUrl: question.titleImageUrl,
      difficulty: question.difficulty,
      type: question.type,
      showBadges: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...question.data.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isStudentAnswer = studentAnswer == option.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGradingOption(
                option,
                index,
                isStudentAnswer,
                theme,
                t,
              ),
            );
          }),
          if (studentAnswer == null) ...[
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

  Widget _buildGradingOption(
    MultipleChoiceOption option,
    int index,
    bool isStudentAnswer,
    ThemeData theme,
    Translations t,
  ) {
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color borderColor;
    Color badgeColor;

    if (option.isCorrect) {
      backgroundColor = Colors.green.shade50;
      borderColor = Colors.green;
      badgeColor = Colors.green;
    } else if (isStudentAnswer) {
      backgroundColor = Colors.red.shade50;
      borderColor = Colors.red;
      badgeColor = Colors.red;
    } else {
      backgroundColor = colorScheme.surfaceContainerLow;
      borderColor = colorScheme.outlineVariant;
      badgeColor = colorScheme.surfaceContainerHigh;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: (option.isCorrect || isStudentAnswer) ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Option letter badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                String.fromCharCode(65 + index), // A, B, C, D
                style: theme.textTheme.titleMedium?.copyWith(
                  color: (option.isCorrect || isStudentAnswer)
                      ? Colors.white
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Option text
          Expanded(
            child: Text(
              option.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Indicators
          Wrap(
            spacing: 8,
            children: [
              if (option.isCorrect)
                _buildLabel(Colors.green, Icons.check, theme),
              if (isStudentAnswer && !option.isCorrect)
                _buildLabel(
                  Colors.red,
                  Icons.person,
                  theme,
                ), // Or specific "Student Answer"
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(Color color, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, size: 14, color: Colors.white),
    );
  }
}
