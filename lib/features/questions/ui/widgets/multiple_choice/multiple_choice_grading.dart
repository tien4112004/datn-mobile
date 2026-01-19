import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/ui/widgets/question_card_wrapper.dart';

/// Multiple Choice Question in Grading Mode (Teacher reviewing student answer)
/// Enhanced with Material 3 design principles
class MultipleChoiceGrading extends StatelessWidget {
  final MultipleChoiceQuestion question;
  final String? studentAnswer;

  const MultipleChoiceGrading({
    super.key,
    required this.question,
    this.studentAnswer,
  });

  bool get _isCorrect {
    if (studentAnswer == null) return false;
    final correctOption = question.data.options.firstWhere(
      (opt) => opt.isCorrect,
      orElse: () => question.data.options.first,
    );
    return studentAnswer == correctOption.id;
  }

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.grading_outlined,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Grading Mode',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Result badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _isCorrect ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.cancel,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isCorrect ? 'Correct' : 'Incorrect',
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
          ...question.data.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isStudentAnswer = studentAnswer == option.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildGradingOption(option, index, isStudentAnswer, theme),
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
                      'Student did not answer this question',
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
                _buildLabel('Correct', Colors.green, Icons.check_circle, theme),
              if (isStudentAnswer && !option.isCorrect)
                _buildLabel('Student Answer', Colors.red, Icons.person, theme),
              if (isStudentAnswer && option.isCorrect)
                _buildLabel('Student Answer', Colors.blue, Icons.person, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, Color color, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
