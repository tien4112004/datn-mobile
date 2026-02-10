import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/features/submissions/domain/entity/statistics_entity.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

class _StatBadgeData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBadgeData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class StatisticsOverviewCard extends ConsumerWidget {
  final SubmissionStatisticsEntity statistics;
  final double? maxScore;

  const StatisticsOverviewCard({
    super.key,
    required this.statistics,
    this.maxScore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define all stat badges in a list
    final statBadges = [
      _StatBadgeData(
        icon: LucideIcons.fileText,
        label: t.submissions.statistics.totalSubmissions,
        value: statistics.totalSubmissions.toString(),
        color: colorScheme.primary,
      ),
      _StatBadgeData(
        icon: LucideIcons.circleCheck,
        label: t.submissions.statistics.graded,
        value: statistics.gradedCount.toString(),
        color: Colors.green,
      ),
      _StatBadgeData(
        icon: LucideIcons.clock,
        label: t.submissions.statistics.pending,
        value: statistics.pendingCount.toString(),
        color: Colors.orange,
      ),
      _StatBadgeData(
        icon: LucideIcons.pencil,
        label: t.submissions.statistics.inProgress,
        value: statistics.inProgressCount.toString(),
        color: colorScheme.secondary,
      ),
      if (maxScore != null)
        _StatBadgeData(
          icon: LucideIcons.target,
          label: t.submissions.statistics.maxScore,
          value: maxScore!.toStringAsFixed(0),
          color: colorScheme.tertiary,
        ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.chartBar, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                t.submissions.statistics.overview,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 5,
              crossAxisCount: 2,
            ),
            itemCount: statBadges.length,
            itemBuilder: (context, index) {
              final stat = statBadges[index];
              return _buildStatBadge(stat, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(_StatBadgeData stat, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stat.value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: stat.color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            stat.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: stat.color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
