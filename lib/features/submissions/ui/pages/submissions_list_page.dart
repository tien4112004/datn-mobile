import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/submissions/domain/entity/submission_entity.dart';
import 'package:AIPrimary/features/submissions/states/controller_provider.dart';
import 'package:AIPrimary/features/submissions/ui/widgets/submission_status_badge.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
  String _sortBy = 'date'; // date, score, name

  List<SubmissionEntity> _filterAndSort(List<SubmissionEntity> submissions) {
    var filtered = submissions;

    // Filter by status
    if (_filterStatus != null) {
      filtered = filtered.where((s) => s.status == _filterStatus).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'date':
        filtered.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
        break;
      case 'score':
        filtered.sort((a, b) {
          final scoreA = a.score ?? 0;
          final scoreB = b.score ?? 0;
          return scoreB.compareTo(scoreA);
        });
        break;
      case 'name':
        filtered.sort(
          (a, b) => a.student.firstName.compareTo(b.student.firstName),
        );
        break;
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
              // Filters and sorting
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: Text(t.submissions.list.filterAll),
                            selected: _filterStatus == null,
                            onSelected: (selected) {
                              setState(() => _filterStatus = null);
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: Text(t.submissions.list.filterSubmitted),
                            selected:
                                _filterStatus == SubmissionStatus.submitted,
                            onSelected: (selected) {
                              setState(() {
                                _filterStatus = selected
                                    ? SubmissionStatus.submitted
                                    : null;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: Text(t.submissions.list.filterGraded),
                            selected: _filterStatus == SubmissionStatus.graded,
                            onSelected: (selected) {
                              setState(() {
                                _filterStatus = selected
                                    ? SubmissionStatus.graded
                                    : null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Sort dropdown
                    DropdownButton<String>(
                      value: _sortBy,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: 'date',
                          child: Text(t.submissions.list.sortByDate),
                        ),
                        DropdownMenuItem(
                          value: 'score',
                          child: Text(t.submissions.list.sortByScore),
                        ),
                        DropdownMenuItem(
                          value: 'name',
                          child: Text(t.submissions.list.sortByName),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _sortBy = value);
                        }
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
        context.router.push(SubmissionDetailRoute(submissionId: submission.id));
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
