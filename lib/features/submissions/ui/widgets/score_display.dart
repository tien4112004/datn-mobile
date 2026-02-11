import 'package:flutter/material.dart';

/// Widget displaying score with color coding
class ScoreDisplay extends StatelessWidget {
  final double score;
  final double maxScore;

  const ScoreDisplay({super.key, required this.score, required this.maxScore});

  Color _getColorForPercentage(double percentage) {
    if (percentage >= 90) {
      return Colors.green;
    } else if (percentage >= 70) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double percentage = maxScore > 0 ? (score / maxScore) * 100 : 0;
    final color = _getColorForPercentage(percentage);

    return Column(
      children: [
        Text(
          '${score.toStringAsFixed(1)}/${maxScore.toStringAsFixed(1)}',
          style: theme.textTheme.displaySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
