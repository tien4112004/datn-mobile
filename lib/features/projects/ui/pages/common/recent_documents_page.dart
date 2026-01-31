import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/projects/states/recent_documents_provider.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/project_loading_skeleton.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/recent_document_card.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/widgets/enhanced_empty_state.dart';
import 'package:AIPrimary/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class RecentDocumentsPage extends ConsumerStatefulWidget {
  const RecentDocumentsPage({super.key});

  @override
  ConsumerState<RecentDocumentsPage> createState() =>
      _RecentDocumentsPageState();
}

class _RecentDocumentsPageState extends ConsumerState<RecentDocumentsPage> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recentDocumentsProvider.notifier).loadRecentDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final recentDocumentsState = ref.watch(recentDocumentsProvider);

    return Scaffold(
      appBar: CustomAppBar(title: t.projects.recently_works),
      body: recentDocumentsState.easyWhen(
        data: (state) => state.documents.isEmpty
            ? EnhancedEmptyState(
                icon: Icons.history,
                title: t.projects.no_recent_works,
                message: 'Your recent work will appear here',
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref
                      .read(recentDocumentsProvider.notifier)
                      .loadRecentDocuments();
                },
                child: GridView.builder(
                  padding: EdgeInsets.all(Themes.padding.p16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: state.documents.length,
                  itemBuilder: (context, index) => RecentDocumentCard(
                    recentDocument: state.documents[index],
                  ),
                ),
              ),
        loadingWidget: () => const ProjectGridSkeletonLoader(),
        onRetry: () {
          ref.read(recentDocumentsProvider.notifier).loadRecentDocuments();
        },
      ),
    );
  }
}
