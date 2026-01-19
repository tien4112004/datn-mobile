import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/ui/widgets/question_card_wrapper.dart';

/// Multiple Choice Question in After Assessment Mode (Student reviewing their answer)
class MultipleChoiceAfterAssess extends StatelessWidget {
  final MultipleChoiceQuestion question;
  final String? studentAnswer;

  const MultipleChoiceAfterAssess({
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
      explanation: question.explanation,
      showExplanation: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'YOUR RESULT',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.indigo,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _isCorrect ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isCorrect ? 'CORRECT' : 'INCORRECT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...question.data.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isStudentAnswer = studentAnswer == option.id;

            return _buildResultOption(option, index, isStudentAnswer, theme);
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
                  const Text('You did not answer this question'),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (option.isCorrect)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'CORRECT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isStudentAnswer && !option.isCorrect) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'YOUR ANSWER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            if (isStudentAnswer && option.isCorrect) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'YOUR ANSWER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
