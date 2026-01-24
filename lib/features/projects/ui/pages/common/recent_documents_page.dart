import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/domain/entity/recent_document.dart';
import 'package:datn_mobile/features/projects/providers/paging_controller_pod.dart';
import 'package:datn_mobile/features/projects/ui/widgets/common/recent_document_card.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

@RoutePage()
class RecentDocumentsPage extends ConsumerWidget {
  const RecentDocumentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final pagingController = ref.watch(recentDocumentsPagingControllerPod);

    return Scaffold(
      appBar: CustomAppBar(title: t.projects.recently_works),
      body: Padding(
        padding: EdgeInsets.all(Themes.padding.p16),
        child: PagedGridView<int, RecentDocument>(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          builderDelegate: PagedChildBuilderDelegate<RecentDocument>(
            itemBuilder: (context, recentDocument, index) =>
                RecentDocumentCard(recentDocument: recentDocument),
            firstPageErrorIndicatorBuilder: (context) => Center(
              child: Text(
                'Error loading recent documents',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: Themes.fontSize.s16,
                ),
              ),
            ),
            noItemsFoundIndicatorBuilder: (context) => Center(
              child: Text(
                t.projects.no_recent_works,
                style: TextStyle(
                  fontSize: Themes.fontSize.s16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          state: pagingController.value,
          fetchNextPage: pagingController.fetchNextPage,
        ),
      ),
    );
  }
}
