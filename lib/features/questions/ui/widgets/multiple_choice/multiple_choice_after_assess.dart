import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Multiple Choice Question in After Assessment Mode (Student reviewing their answer)
class MultipleChoiceAfterAssess extends ConsumerWidget {
  final MultipleChoiceQuestion question;
  final String? studentAnswer;

  const MultipleChoiceAfterAssess({
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
      explanation: question.explanation,
      showExplanation: true,
      showBadges: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...question.data.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isStudentAnswer = studentAnswer == option.id;

            return _buildResultOption(option, index, isStudentAnswer, theme, t);
          }),
          if (studentAnswer == null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(t.questionBank.multipleChoice.notAnswered),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultOption(
    MultipleChoiceOption option,
    int index,
    bool isStudentAnswer,
    ThemeData theme,
    Translations t,
  ) {
    Color borderColor = Colors.grey[300]!;
    Color? backgroundColor;

    if (option.isCorrect) {
      borderColor = Colors.green;
      backgroundColor = Colors.green.withValues(alpha: 0.05);
    }

    if (isStudentAnswer && !option.isCorrect) {
      borderColor = Colors.red;
      backgroundColor = Colors.red.withValues(alpha: 0.05);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: (option.isCorrect || isStudentAnswer) ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: backgroundColor,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: option.isCorrect
              ? Colors.green
              : (isStudentAnswer ? Colors.red : Colors.grey[300]),
          child: Text(
            String.fromCharCode(65 + index), // A, B, C, D
            style: TextStyle(
              color: (option.isCorrect || isStudentAnswer)
                  ? Colors.white
                  : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(option.text, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}
