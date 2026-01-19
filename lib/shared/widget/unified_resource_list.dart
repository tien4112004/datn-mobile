import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/shared/widget/enhanced_empty_state.dart';
import 'package:datn_mobile/shared/widget/enhanced_error_state.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Unified resource list widget that supports both grid and list views
///
/// This widget provides a consistent list/grid experience across all resource types:
/// - Pagination support with PagingController
/// - Grid or list layout based on preference
/// - Empty state handling
/// - Error state handling
/// - Pull-to-refresh
///
/// Type parameter:
/// - T: The resource type (e.g., ImageProjectMinimal, PresentationMinimal)
///
/// Usage:
/// ```dart
/// UnifiedResourceList<ImageProjectMinimal>(
///   pagingController: pagingController,
///   isGridView: isGridView,
///   gridCardBuilder: (item) => ImageGridCard(image: item),
///   listTileBuilder: (item) => ImageTile(image: item),
///   emptyIcon: LucideIcons.image,
///   emptyTitle: 'No images',
///   emptyMessage: 'Create your first image',
/// )
/// ```
class UnifiedResourceList<T> extends StatelessWidget {
  final PagingController<int, T> pagingController;
  final bool isGridView;
  final Widget Function(T item) gridCardBuilder;
  final Widget Function(T item) listTileBuilder;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final String noMoreItemsText;
  final VoidCallback onRefresh;

  const UnifiedResourceList({
    super.key,
    required this.pagingController,
    required this.isGridView,
    required this.gridCardBuilder,
    required this.listTileBuilder,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.noMoreItemsText,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: PagingListener(
        controller: pagingController,
        builder: (context, state, fetchNextPage) {
          if (isGridView) {
            return _buildGridView(state, fetchNextPage);
          } else {
            return _buildListView(state, fetchNextPage);
          }
        },
      ),
    );
  }

  Widget _buildGridView(PagingState<int, T> state, VoidCallback fetchNextPage) {
    return PagedGridView<int, T>(
      state: state,
      fetchNextPage: fetchNextPage,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      builderDelegate: PagedChildBuilderDelegate<T>(
        itemBuilder: (context, item, index) => gridCardBuilder(item),
        noMoreItemsIndicatorBuilder: (context) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              noMoreItemsText,
              style: TextStyle(
                fontSize: Themes.fontSize.s14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
        noItemsFoundIndicatorBuilder: (context) => EnhancedEmptyState(
          icon: emptyIcon,
          title: emptyTitle,
          message: emptyMessage,
        ),
        firstPageErrorIndicatorBuilder: (context) => EnhancedErrorState(
          title: 'Error loading resources',
          message: state.error?.toString() ?? 'Unknown error',
          actionLabel: 'Retry',
          onRetry: onRefresh,
        ),
        newPageErrorIndicatorBuilder: (context) => Center(
          child: Text(
            'Error loading more items',
            style: TextStyle(
              fontSize: Themes.fontSize.s14,
              color: Colors.red.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView(PagingState<int, T> state, VoidCallback fetchNextPage) {
    return PagedListView.separated(
      state: state,
      fetchNextPage: fetchNextPage,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      separatorBuilder: (context, index) => const SizedBox(
        child: Divider(height: 1, color: Color.fromRGBO(189, 189, 189, 1)),
      ),
      builderDelegate: PagedChildBuilderDelegate<T>(
        itemBuilder: (context, item, index) => listTileBuilder(item),
        noMoreItemsIndicatorBuilder: (context) => Padding(
          padding: const EdgeInsets.all(0),
          child: Center(
            child: Text(
              noMoreItemsText,
              style: TextStyle(
                fontSize: Themes.fontSize.s14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
        noItemsFoundIndicatorBuilder: (context) => EnhancedEmptyState(
          icon: emptyIcon,
          title: emptyTitle,
          message: emptyMessage,
        ),
        firstPageErrorIndicatorBuilder: (context) => EnhancedErrorState(
          title: 'Error loading resources',
          message: state.error?.toString() ?? 'Unknown error',
          actionLabel: 'Retry',
          onRetry: onRefresh,
        ),
        newPageErrorIndicatorBuilder: (context) => Center(
          child: Text(
            'Error loading more items',
            style: TextStyle(
              fontSize: Themes.fontSize.s14,
              color: Colors.red.shade600,
            ),
          ),
        ),
      ),
    );
  }
}
