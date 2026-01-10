import 'package:datn_mobile/features/classes/domain/entity/class_entity.dart';
import 'package:datn_mobile/features/classes/domain/entity/post_entity.dart';
import 'package:datn_mobile/features/classes/providers/post_paging_controller_pod.dart';
import 'package:datn_mobile/features/classes/ui/pages/post_upsert_page.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/post_card.dart';
import 'package:datn_mobile/shared/widget/animated_list_item.dart';
import 'package:datn_mobile/shared/widget/enhanced_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// List of posts with pull-to-refresh and pagination
class PostList extends ConsumerStatefulWidget {
  final ClassEntity classEntity;

  const PostList({super.key, required this.classEntity});

  @override
  ConsumerState<PostList> createState() => _PostListState();
}

class _PostListState extends ConsumerState<PostList> {
  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    final controller = ref.read(postPagingControllerPod(widget.classEntity.id));
    controller.refresh();
  }

  Future<void> _navigateToCreatePost() async {
    HapticFeedback.mediumImpact();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PostUpsertPage(classId: widget.classEntity.id),
      ),
    );

    // Refresh posts if creation was successful
    if (result == true && mounted) {
      final controller = ref.read(
        postPagingControllerPod(widget.classEntity.id),
      );
      controller.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagingController = ref.watch(
      postPagingControllerPod(widget.classEntity.id),
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: PagingListener(
          controller: pagingController,
          builder: (context, state, fetchNextPage) =>
              PagedListView<int, PostEntity>.separated(
                padding: const EdgeInsets.only(bottom: 80),
                separatorBuilder: (context, index) => const SizedBox(height: 0),
                state: state,
                fetchNextPage: fetchNextPage,
                builderDelegate: PagedChildBuilderDelegate(
                  itemBuilder: (context, item, index) {
                    return AnimatedListItem(
                      index: index,
                      child: PostCard(
                        key: ValueKey(item.id),
                        post: item,
                        classEntity: widget.classEntity,
                      ),
                    );
                  },
                  firstPageErrorIndicatorBuilder: (context) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.circleAlert,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading posts',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.error?.toString() ?? 'Unknown error',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => pagingController.refresh(),
                            icon: const Icon(LucideIcons.refreshCw, size: 18),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  noItemsFoundIndicatorBuilder: (context) => EnhancedEmptyState(
                    icon: LucideIcons.messageSquare,
                    title: 'No Posts Yet',
                    message:
                        'Your teacher will post announcements and updates here.',
                    actionLabel: 'Create First Post',
                    onAction: _navigateToCreatePost,
                  ),
                  newPageProgressIndicatorBuilder: (context) => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  noMoreItemsIndicatorBuilder: (context) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No more posts',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        ),
      ),
      floatingActionButton: Semantics(
        label: 'Create new post',
        button: true,
        child: FloatingActionButton.extended(
          onPressed: _navigateToCreatePost,
          icon: const Icon(LucideIcons.plus),
          label: const Text('New Post'),
        ),
      ),
    );
  }
}
