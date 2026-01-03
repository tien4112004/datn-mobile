import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/ui/widgets/question_card_wrapper.dart';

/// Open Ended Question in Grading Mode
class OpenEndedGrading extends StatefulWidget {
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
  State<OpenEndedGrading> createState() => _OpenEndedGradingState();
}

class _OpenEndedGradingState extends State<OpenEndedGrading> {
  int? _currentScore;

  @override
  void initState() {
    super.initState();
    _currentScore = widget.score;
  }

  void _setScore(int score) {
    setState(() {
      _currentScore = score;
    });
    widget.onScoreChanged?.call(score);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxPoints = widget.question.points ?? 10;

    return QuestionCardWrapper(
      title: widget.question.title,
      titleImageUrl: widget.question.titleImageUrl,
      difficulty: widget.question.difficulty,
      points: widget.question.points,
      type: widget.question.type,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GRADING MODE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Student's Answer
          Text(
            'Student\'s Answer:',
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
              widget.studentAnswer ?? 'No answer provided',
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
              'Expected Answer (Reference):',
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
            'Assign Score:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(maxPoints + 1, (index) {
                final isSelected = _currentScore == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('$index'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) _setScore(index);
                    },
                    selectedColor: Colors.green,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
