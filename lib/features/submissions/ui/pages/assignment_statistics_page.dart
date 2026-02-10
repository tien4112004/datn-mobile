import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/features/assignments/states/controller_provider.dart';
import 'package:AIPrimary/features/submissions/states/controller_provider.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import '../widgets/statistics_overview_card.dart';
import '../widgets/score_statistics_card.dart';
import '../widgets/score_distribution_card.dart';
import '../widgets/view_submissions_button.dart';

@RoutePage()
class AssignmentStatisticsPage extends ConsumerWidget {
  final String postId;

  const AssignmentStatisticsPage({
    super.key,
    @PathParam('postId') required this.postId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final statisticsAsync = ref.watch(submissionStatisticsProvider(postId));
    // Fetch assignment details using the post endpoint
    final assignmentAsync = ref.watch(assignmentPostProvider(postId));

    return Scaffold(
      appBar: AppBar(
        // Display assignment title if available, otherwise generic title
        title: assignmentAsync.when(
          data: (assignment) => Text(assignment.title),
          loading: () => Text(t.submissions.statistics.title),
          error: (_, _) => Text(t.submissions.statistics.title),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () =>
                ref.invalidate(submissionStatisticsProvider(postId)),
          ),
        ],
      ),
      body: statisticsAsync.easyWhen(
        skipLoadingOnRefresh: false,
        data: (statistics) {
          // Get maxScore from assignment if available
          final maxScore = assignmentAsync.maybeWhen(
            data: (assignment) => assignment.totalPoints.toDouble(),
            orElse: () => null,
          );

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(submissionStatisticsProvider(postId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StatisticsOverviewCard(
                    statistics: statistics,
                    maxScore: maxScore,
                  ),
                  const SizedBox(height: 16),
                  ScoreStatisticsCard(statistics: statistics),
                  const SizedBox(height: 16),
                  ScoreDistributionCard(statistics: statistics),
                  const SizedBox(height: 24),
                  ViewSubmissionsButton(postId: postId),
                ],
              ),
            ),
          );
        },
        loadingWidget: () => const Center(child: CircularProgressIndicator()),
        errorWidget: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.circleAlert,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(t.submissions.statistics.errorLoadFailed),
            ],
          ),
        ),
      ),
    );
  }
}
