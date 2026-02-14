import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/notification/ui/widgets/notification_bell.dart';
import 'package:AIPrimary/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/home/providers/analytics_providers.dart';
import 'package:AIPrimary/features/home/providers/recent_documents_provider.dart';
import 'package:AIPrimary/features/home/ui/widgets/dashboard_summary_metrics.dart';
import 'package:AIPrimary/features/home/ui/widgets/dashboard_calendar_widget.dart';
import 'package:AIPrimary/features/home/ui/widgets/dashboard_recent_activity.dart';
import 'package:AIPrimary/features/home/ui/widgets/dashboard_resource_banner.dart';
import 'package:AIPrimary/features/home/ui/widgets/dashboard_modals.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _HomeAppBar(),
      body: SafeArea(child: _HomeView()),
    );
  }
}

class _HomeView extends ConsumerWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final summaryAsync = ref.watch(teacherSummaryProvider);
    final calendarAsync = ref.watch(teacherCalendarProvider);
    final recentDocsAsync = ref.watch(recentDocumentsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(teacherSummaryProvider);
        ref.invalidate(teacherCalendarProvider);
        ref.invalidate(recentDocumentsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Text(
                t.home.dashboard.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.home.dashboard.subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),

              // Summary Metrics Cards
              summaryAsync.when(
                data: (summary) => DashboardSummaryMetrics(
                  summary: summary,
                  onTotalClassesTap: () =>
                      showClassesOverviewModal(context, ref),
                  onPendingGradingTap: () =>
                      showPendingGradingModal(context, ref),
                ),
                loading: () => const DashboardSummaryMetricsShimmer(),
                error: (error, stack) =>
                    Center(child: Text(t.home.dashboard.error.loadingSummary)),
              ),
              const SizedBox(height: 24),

              // Resource Generation Banner
              DashboardResourceBanner(
                onGenerateTap: () {
                  context.router.push(const GenerateRoute());
                },
              ),
              const SizedBox(height: 24),

              // Calendar Widget
              calendarAsync.when(
                data: (events) => DashboardCalendarWidget(events: events),
                loading: () => const DashboardCalendarShimmer(),
                error: (error, stack) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Recent Documents
              recentDocsAsync.when(
                data: (documents) =>
                    DashboardRecentDocuments(documents: documents),
                loading: () => const DashboardRecentDocumentsShimmer(),
                error: (error, stack) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final t = ref.watch(translationsPod);

        return CustomAppBar(
          title: t.homeGreeting,
          actions: [
            NotificationBell(
              onTap: () {
                context.router.push(const NotificationListRoute());
              },
            ),
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(right: 16, top: 4, bottom: 4),
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: Themes.boxRadius,
                  ),
                  child: InkWell(
                    onTap: () {
                      // TODO: Navigate to credits/purchase page
                      debugPrint('Credits tapped');
                    },
                    borderRadius: Themes.boxRadius,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.coins,
                            size: 20,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '1,250 credits', // TODO: Replace with actual user credits
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
