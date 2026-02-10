import 'package:AIPrimary/core/router/router.gr.dart';
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

    return Scaffold(
      appBar: AppBar(title: Text(t.submissions.list.title)),
      body: submissionsAsync.easyWhen(
        skipLoadingOnRefresh: false,
        data: (submissions) {
          final filtered = _filterAndSort(submissions);

          return Column(
            children: [
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
}
