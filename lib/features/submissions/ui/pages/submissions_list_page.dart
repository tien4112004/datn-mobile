import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/submissions/domain/entity/statistics_entity.dart';
import 'package:AIPrimary/features/submissions/domain/entity/submission_entity.dart';
import 'package:AIPrimary/features/submissions/states/controller_provider.dart';
import 'package:AIPrimary/features/submissions/ui/widgets/submission_status_badge.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/widgets/custom_search_bar.dart';
import 'package:AIPrimary/shared/widgets/generic_filters_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum SubmissionSortOption {
  date,
  score,
  name;

  String displayName(Translations t) {
    switch (this) {
      case SubmissionSortOption.date:
        return t.submissions.list.sortByDate;
      case SubmissionSortOption.score:
        return t.submissions.list.sortByScore;
      case SubmissionSortOption.name:
        return t.submissions.list.sortByName;
    }
  }

  IconData get icon {
    switch (this) {
      case SubmissionSortOption.date:
        return LucideIcons.calendar;
      case SubmissionSortOption.score:
        return LucideIcons.award;
      case SubmissionSortOption.name:
        return LucideIcons.user;
    }
  }
}

@RoutePage()
class SubmissionsListPage extends ConsumerStatefulWidget {
  final String postId;

  const SubmissionsListPage({
    super.key,
    @PathParam('postId') required this.postId,
  });

  @override
  ConsumerState<SubmissionsListPage> createState() =>
      _SubmissionsListPageState();
}

class _SubmissionsListPageState extends ConsumerState<SubmissionsListPage> {
  SubmissionStatus? _filterStatus;
  SubmissionSortOption? _sortBy = SubmissionSortOption.date;
  String _searchQuery = '';

  IconData _getStatusIcon(SubmissionStatus status) {
    switch (status) {
      case SubmissionStatus.submitted:
        return LucideIcons.clock;
      case SubmissionStatus.graded:
        return LucideIcons.circleCheck;
      case SubmissionStatus.inProgress:
        return LucideIcons.pencil;
    }
  }

  String _getStatusDisplayName(SubmissionStatus status, Translations t) {
    switch (status) {
      case SubmissionStatus.submitted:
        return t.submissions.list.filterSubmitted;
      case SubmissionStatus.graded:
        return t.submissions.list.filterGraded;
      case SubmissionStatus.inProgress:
        return t.submissions.status.inProgress;
    }
  }

  List<SubmissionEntity> _filterAndSort(List<SubmissionEntity> submissions) {
    var filtered = submissions;

    // Filter by status
    if (_filterStatus != null) {
      filtered = filtered.where((s) => s.status == _filterStatus).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        final fullName = '${s.student.firstName} ${s.student.lastName}'
            .toLowerCase();
        final email = s.student.email.toLowerCase();
        return fullName.contains(query) || email.contains(query);
      }).toList();
    }

    // Sort
    if (_sortBy != null) {
      switch (_sortBy!) {
        case SubmissionSortOption.date:
          filtered.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
          break;
        case SubmissionSortOption.score:
          filtered.sort((a, b) {
            final scoreA = a.score ?? 0;
            final scoreB = b.score ?? 0;
            return scoreB.compareTo(scoreA);
          });
          break;
        case SubmissionSortOption.name:
          filtered.sort(
            (a, b) => a.student.firstName.compareTo(b.student.firstName),
          );
          break;
      }
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final submissionsAsync = ref.watch(postSubmissionsProvider(widget.postId));
    final statisticsAsync = ref.watch(
      submissionStatisticsProvider(widget.postId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(t.submissions.list.title)),
      body: submissionsAsync.easyWhen(
        skipLoadingOnRefresh: false,
        data: (submissions) {
          final filtered = _filterAndSort(submissions);

          return Column(
            children: [
              // Statistics Card
              statisticsAsync.when(
                data: (stats) => _buildStatisticsCard(context, stats, t),
                loading: () => _buildStatisticsLoadingCard(context),
                error: (error, stack) => const SizedBox.shrink(),
              ),
              // Search and Filters
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: CustomSearchBar(
                        hintText: t.submissions.list.searchHint,
                        enabled: true,
                        autoFocus: false,
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                        onClearTap: () {
                          setState(() => _searchQuery = '');
                        },
                      ),
                    ),

                    // Filter bar
                    GenericFiltersBar(
                      filters: [
                        FilterConfig<SubmissionStatus>(
                          label: t.submissions.list.status,
                          icon: LucideIcons.fileText,
                          selectedValue: _filterStatus,
                          options: SubmissionStatus.values,
                          displayNameBuilder: (status) =>
                              _getStatusDisplayName(status, t),
                          iconBuilder: _getStatusIcon,
                          onChanged: (status) {
                            setState(() => _filterStatus = status);
                          },
                          allLabel: t.submissions.list.filterAll,
                          allIcon: LucideIcons.fileText,
                        ),
                        FilterConfig<SubmissionSortOption>(
                          label: t.submissions.list.sortBy,
                          icon: LucideIcons.arrowUpDown,
                          selectedValue: _sortBy,
                          options: SubmissionSortOption.values,
                          displayNameBuilder: (sort) => sort.displayName(t),
                          iconBuilder: (sort) => sort.icon,
                          onChanged: (sort) {
                            setState(() => _sortBy = sort);
                          },
                          allLabel: t.submissions.list.filterAll,
                          allIcon: LucideIcons.arrowUpDown,
                        ),
                      ],
                      onClearFilters: () {
                        setState(() {
                          _filterStatus = null;
                          _sortBy = SubmissionSortOption.date;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // List of submissions
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.inbox,
                              size: 64,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              t.submissions.list.noSubmissions,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(
                            postSubmissionsProvider(widget.postId),
                          );
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final submission = filtered[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildSubmissionCard(
                                context,
                                submission,
                                t,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
        loadingWidget: () => const Center(child: CircularProgressIndicator()),
        errorWidget: (error, stack) =>
            Center(child: Text(t.submissions.errors.loadFailed)),
      ),
    );
  }

  Widget _buildSubmissionCard(
    BuildContext context,
    SubmissionEntity submission,
    Translations t,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        // Teachers go directly to grading page
        context.router.push(GradingRoute(submissionId: submission.id));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submission.student.firstName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        submission.student.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SubmissionStatusBadge(status: submission.status),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat.yMMMd().add_jm().format(submission.submittedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                if (submission.score != null) ...[
                  const SizedBox(width: 16),
                  Icon(LucideIcons.award, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${submission.score!.toStringAsFixed(1)}/${submission.maxScore} (${submission.scorePercentage.toStringAsFixed(0)}%)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const Spacer(),

                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(
    BuildContext context,
    SubmissionStatisticsEntity stats,
    Translations t,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(LucideIcons.chartBar, color: colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Statistics',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Statistics Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Total',
                  value: stats.totalSubmissions.toString(),
                  icon: LucideIcons.fileText,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  label: t.submissions.list.filterGraded,
                  value: stats.gradedCount.toString(),
                  icon: LucideIcons.circleCheck,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  label: t.submissions.list.filterSubmitted,
                  value: stats.pendingCount.toString(),
                  icon: LucideIcons.clock,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  label: t.submissions.status.inProgress,
                  value: stats.inProgressCount.toString(),
                  icon: LucideIcons.pencil,
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          // Average Score (if available)
          if (stats.averageScore != null && stats.totalSubmissions > 0) ...[
            const SizedBox(height: 16),
            Divider(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average Score',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.averageScore!.toStringAsFixed(1)}%',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                if (stats.highestScore != null && stats.lowestScore != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.trendingUp,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${stats.highestScore!.toStringAsFixed(1)}%',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.trendingDown,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${stats.lowestScore!.toStringAsFixed(1)}%',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsLoadingCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Loading statistics...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
