import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/home/data/models/at_risk_student_model.dart';
import 'package:AIPrimary/features/home/data/models/class_at_risk_students_model.dart';
import 'package:AIPrimary/features/home/data/models/grading_queue_model.dart';
import 'package:AIPrimary/features/home/providers/analytics_providers.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

/// Show Pending Grading Queue Modal
void showPendingGradingModal(BuildContext context, WidgetRef ref) {
  final t = ref.read(translationsPod);
  WoltModalSheet.show(
    context: context,
    pageListBuilder: (context) => [
      WoltModalSheetPage(
        topBarTitle: Text(
          t.home.dashboard.modals.pendingGrading.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        isTopBarLayerAlwaysVisible: true,
        trailingNavBarWidget: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
        child: _GradingQueueModalContent(),
      ),
    ],
  );
}

/// Show Total Classes Overview Modal
void showClassesOverviewModal(BuildContext context, WidgetRef ref) {
  final t = ref.read(translationsPod);
  WoltModalSheet.show(
    context: context,
    pageListBuilder: (context) => [
      WoltModalSheetPage(
        topBarTitle: Text(t.home.dashboard.modals.classesOverview.title),
        isTopBarLayerAlwaysVisible: true,
        trailingNavBarWidget: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
        child: _ClassesOverviewModalContent(),
      ),
    ],
  );
}

/// Grading Queue Modal Content
class _GradingQueueModalContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    return FutureBuilder<List<GradingQueueItemModel>>(
      future: _fetchGradingQueue(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildGradingQueueShimmer();
        }

        if (snapshot.hasError) {
          // Log the actual error for debugging
          return _buildErrorState(t.home.dashboard.modals.pendingGrading.error);
        }

        final queue = snapshot.data ?? [];

        if (queue.isEmpty) {
          return _buildEmptyGradingQueue(t);
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: queue.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _GradingQueueCard(item: queue[index]);
          },
        );
      },
    );
  }

  Future<List<GradingQueueItemModel>> _fetchGradingQueue(WidgetRef ref) async {
    final repository = ref.read(analyticsRepositoryProvider);
    return repository.getGradingQueue(size: 50);
  }

  Widget _buildGradingQueueShimmer() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: Themes.boxRadius,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyGradingQueue(dynamic t) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            const Icon(LucideIcons.circleCheck, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              t.home.dashboard.modals.pendingGrading.empty.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.home.dashboard.modals.pendingGrading.empty.description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            Icon(LucideIcons.circleAlert, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grading Queue Card (Vertical version for modal)
class _GradingQueueCard extends StatelessWidget {
  final GradingQueueItemModel item;

  const _GradingQueueCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final urgentColor = item.daysSinceSubmission >= 3
        ? colorScheme.error
        : item.daysSinceSubmission >= 2
        ? Colors.orange
        : colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: Themes.boxRadius,
        border: Border.all(
          color: urgentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to grading page
          },
          borderRadius: Themes.boxRadius,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: item.student.avatar != null
                          ? NetworkImage(item.student.avatar!)
                          : null,
                      child: item.student.avatar == null
                          ? Text(
                              '${item.student.firstName[0]}${item.student.lastName[0]}'
                                  .toUpperCase(),
                              style: const TextStyle(fontSize: 14),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.student.firstName} ${item.student.lastName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.className,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: urgentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.daysSinceSubmission}d ago',
                        style: TextStyle(
                          color: urgentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.assignmentTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.autoGradedScore != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.circleCheck,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Auto-graded: ${item.autoGradedScore!.toStringAsFixed(0)}/${item.maxScore?.toStringAsFixed(0) ?? "100"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Classes Overview Modal Content
class _ClassesOverviewModalContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final classesAsync = ref.watch(allClassesAtRiskStudentsProvider);

    return classesAsync.when(
      data: (classes) {
        if (classes.isEmpty) {
          return _buildEmptyClasses(t);
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: classes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _ClassOverviewCard(classData: classes[index]);
          },
        );
      },
      loading: () => _buildClassesShimmer(),
      error: (error, stack) =>
          _buildErrorState(t.home.dashboard.modals.classesOverview.error),
    );
  }

  Widget _buildClassesShimmer() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: Themes.boxRadius,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyClasses(dynamic t) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            Icon(LucideIcons.school, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              t.home.dashboard.modals.classesOverview.empty.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.home.dashboard.modals.classesOverview.empty.description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            Icon(LucideIcons.circleAlert, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

/// Class Overview Card
class _ClassOverviewCard extends StatefulWidget {
  final ClassAtRiskStudentsModel classData;

  const _ClassOverviewCard({required this.classData});

  @override
  State<_ClassOverviewCard> createState() => _ClassOverviewCardState();
}

class _ClassOverviewCardState extends State<_ClassOverviewCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasAtRisk = widget.classData.atRiskCount > 0;

    return Consumer(
      builder: (context, ref, child) {
        final t = ref.watch(translationsPod);
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: Themes.boxRadius,
            border: Border.all(
              color: hasAtRisk
                  ? Colors.orange.withValues(alpha: 0.3)
                  : colorScheme.outlineVariant,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (hasAtRisk) {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    }
                  },
                  borderRadius: Themes.boxRadius,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                LucideIcons.school,
                                color: colorScheme.onPrimaryContainer,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.classData.className,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    t.home.dashboard.modals.classesOverview
                                        .studentsCount(
                                          count: widget.classData.totalStudents,
                                        ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (hasAtRisk)
                              Icon(
                                _isExpanded
                                    ? LucideIcons.chevronUp
                                    : LucideIcons.chevronDown,
                                color: colorScheme.outline,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricChip(
                                icon: LucideIcons.users,
                                label: t
                                    .home
                                    .dashboard
                                    .modals
                                    .classesOverview
                                    .students,
                                value: widget.classData.totalStudents
                                    .toString(),
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MetricChip(
                                icon: LucideIcons.triangleAlert,
                                label: t
                                    .home
                                    .dashboard
                                    .modals
                                    .classesOverview
                                    .atRisk,
                                value: widget.classData.atRiskCount.toString(),
                                color: hasAtRisk ? Colors.orange : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Expandable At-Risk Students List
              if (_isExpanded && hasAtRisk) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.home.dashboard.modals.classesOverview.atRiskStudents,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 280,
                        child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: widget.classData.atRiskStudents.length,
                          itemBuilder: (context, index) {
                            final student =
                                widget.classData.atRiskStudents[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4, top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage:
                                        student.student.avatar != null
                                        ? NetworkImage(student.student.avatar!)
                                        : null,
                                    child: student.student.avatar == null
                                        ? Text(
                                            '${student.student.firstName[0]}${student.student.lastName[0]}'
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${student.student.firstName} ${student.student.lastName}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Wrap(
                                        children: [
                                          Text(
                                            t
                                                .home
                                                .dashboard
                                                .modals
                                                .classesOverview
                                                .completedAssignments(
                                                  count:
                                                      student.totalAssignments -
                                                      student
                                                          .missedSubmissions -
                                                      student.lateSubmissions,
                                                ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _getRiskColor(
                                                student.riskLevel,
                                              ),
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            t
                                                .home
                                                .dashboard
                                                .modals
                                                .classesOverview
                                                .averageScoreLabel(
                                                  score: student.averageScore
                                                      .toStringAsFixed(1),
                                                ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _getRiskColor(
                                                student.riskLevel,
                                              ),
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey.shade300,
                            indent: 48,
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
      },
    );
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Colors.yellow.shade700;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.deepOrange;
      case RiskLevel.critical:
        return Colors.red;
    }
  }
}

/// Metric Chip Widget
class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
