import 'package:flutter/material.dart';

/// Reusable banner showing correct/incorrect status with optional score.
/// Used in afterAssess and grading modes.
class AnswerFeedbackBanner extends StatelessWidget {
  final bool isCorrect;
  final double? score;
  final double? totalPoints;

  const AnswerFeedbackBanner({
    super.key,
    required this.isCorrect,
    this.score,
    this.totalPoints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCorrect ? Colors.green : Colors.red;
    final backgroundColor = isCorrect
        ? Colors.green.withValues(alpha: 0.1)
        : Colors.red.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Correct' : 'Incorrect',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (score != null && totalPoints != null)
                  Text(
                    'Score: ${score!.toStringAsFixed(score! == score!.roundToDouble() ? 0 : 1)}/${totalPoints!.toStringAsFixed(totalPoints! == totalPoints!.roundToDouble() ? 0 : 1)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
          if (score != null && totalPoints != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${score!.toStringAsFixed(score! == score!.roundToDouble() ? 0 : 1)}/${totalPoints!.toStringAsFixed(totalPoints! == totalPoints!.roundToDouble() ? 0 : 1)}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
