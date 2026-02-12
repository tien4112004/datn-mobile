import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/home/data/models/teacher_summary_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

/// Material 3 Summary Metrics Cards in Bento Grid Layout
class DashboardSummaryMetrics extends StatelessWidget {
  final TeacherSummaryModel summary;
  final VoidCallback? onTotalClassesTap;
  final VoidCallback? onPendingGradingTap;

  const DashboardSummaryMetrics({
    super.key,
    required this.summary,
    this.onTotalClassesTap,
    this.onPendingGradingTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: LucideIcons.school,
            label: 'Total Classes',
            value: summary.totalClasses.toString(),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer,
                colorScheme.primaryContainer.withValues(alpha: 0.7),
              ],
            ),
            iconColor: colorScheme.onPrimaryContainer,
            onTap: onTotalClassesTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            icon: LucideIcons.clipboardList,
            label: 'Pending Grading',
            value: summary.pendingGrading.toString(),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.tertiaryContainer,
                colorScheme.tertiaryContainer.withValues(alpha: 0.7),
              ],
            ),
            iconColor: colorScheme.onTertiaryContainer,
            onTap: onPendingGradingTap,
            badge: summary.pendingGrading > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Urgent',
                      style: TextStyle(
                        color: colorScheme.onError,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final LinearGradient gradient;
  final Color iconColor;
  final Widget? badge;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
    required this.iconColor,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: Themes.boxRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: Themes.boxRadius,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: iconColor, size: 28),
                    if (badge != null) badge!,
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: iconColor.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading state for metrics
class DashboardSummaryMetricsShimmer extends StatelessWidget {
  const DashboardSummaryMetricsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _MetricCardShimmer()),
        SizedBox(width: 12),
        Expanded(child: _MetricCardShimmer()),
      ],
    );
  }
}

class _MetricCardShimmer extends StatelessWidget {
  const _MetricCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: Themes.boxRadius,
        ),
      ),
    );
  }
}
