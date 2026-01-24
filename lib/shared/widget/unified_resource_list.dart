import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:datn_mobile/shared/widget/enhanced_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Unified resource list widget that supports both grid and list views
///
/// This widget provides a consistent list/grid experience across all resource types:
/// - AsyncValue-based state management
/// - Grid or list layout based on preference
/// - Empty state handling
/// - Error state handling with retry
/// - Pull-to-refresh
/// - Skeleton loading states
///
/// Type parameter:
/// - T: The resource type (e.g., ImageProjectMinimal, PresentationMinimal)
///
/// Usage:
/// ```dart
/// UnifiedResourceList<ImageProjectMinimal>(
///   asyncItems: imageState.map((state) => state.images),
///   isGridView: isGridView,
///   gridCardBuilder: (item) => ImageGridCard(image: item),
///   listTileBuilder: (item) => ImageTile(image: item),
///   skeletonGridBuilder: () => ProjectGridSkeletonLoader(),
///   skeletonListBuilder: () => ProjectListSkeletonLoader(),
///   emptyIcon: LucideIcons.image,
///   emptyTitle: 'No images',
///   emptyMessage: 'Create your first image',
///   onRefresh: () => ref.read(imageProvider.notifier).loadImages(),
/// )
/// ```
class UnifiedResourceList<T> extends StatelessWidget {
  final AsyncValue<List<T>> asyncItems;
  final bool isGridView;
  final Widget Function(T item) gridCardBuilder;
  final Widget Function(T item) listTileBuilder;
  final Widget Function()? skeletonGridBuilder;
  final Widget Function()? skeletonListBuilder;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final VoidCallback onRefresh;

  const UnifiedResourceList({
    super.key,
    required this.asyncItems,
    required this.isGridView,
    required this.gridCardBuilder,
    required this.listTileBuilder,
    this.skeletonGridBuilder,
    this.skeletonListBuilder,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return asyncItems.easyWhen(
      data: (items) => RefreshIndicator(
        onRefresh: () async {
          onRefresh();
        },
        child: items.isEmpty
            ? _buildEmptyState()
            : (isGridView ? _buildGridView(items) : _buildListView(items)),
      ),
      loadingWidget: () => isGridView
          ? (skeletonGridBuilder?.call() ??
                const Center(child: CircularProgressIndicator()))
          : (skeletonListBuilder?.call() ??
                const Center(child: CircularProgressIndicator())),
      onRetry: onRefresh,
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 400,
        child: EnhancedEmptyState(
          icon: emptyIcon,
          title: emptyTitle,
          message: emptyMessage,
        ),
      ),
    );
  }

  Widget _buildGridView(List<T> items) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => gridCardBuilder(items[index]),
    );
  }

  Widget _buildListView(List<T> items) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (context, index) =>
          const SizedBox(child: Divider(indent: 154, height: 1)),
      itemBuilder: (context, index) => listTileBuilder(items[index]),
    );
  }
}
