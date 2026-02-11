import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/features/submissions/domain/entity/statistics_entity.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

class ScoreStatisticsCard extends ConsumerWidget {
  final SubmissionStatisticsEntity statistics;

  const ScoreStatisticsCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!statistics.hasScores) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Center(child: Text(t.submissions.statistics.noScoresYet)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.3),
            colorScheme.primaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.trophy, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                t.submissions.statistics.scoreStatistics,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildScoreStat(
                label: t.submissions.statistics.average,
                value: statistics.averageScore!,
                color: _getColorForScore(statistics.averageScore!),
                theme: theme,
              ),
              _buildScoreStat(
                label: t.submissions.statistics.highest,
                value: statistics.highestScore!,
                color: Colors.green,
                theme: theme,
              ),
              _buildScoreStat(
                label: t.submissions.statistics.lowest,
                value: statistics.lowestScore!,
                color: Colors.red,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreStat({
    required String label,
    required double value,
    required Color color,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(1),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getColorForScore(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.orange;
    return Colors.red;
  }
}
