import 'package:AIPrimary/features/auth/domain/entities/user_role.dart';
import 'package:AIPrimary/features/classes/domain/entity/class_entity.dart';
import 'package:AIPrimary/features/classes/domain/entity/post_entity.dart';
import 'package:AIPrimary/features/classes/providers/post_paging_controller_pod.dart';
import 'package:AIPrimary/features/posts/ui/pages/create_post_page.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/post_card.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:AIPrimary/shared/widgets/animated_list_item.dart';
import 'package:AIPrimary/shared/widgets/enhanced_empty_state.dart';
import 'package:AIPrimary/shared/widgets/enhanced_error_state.dart';
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
        builder: (context) => CreatePostPage(classId: widget.classEntity.id),
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
    final t = ref.watch(translationsPod);
    final isStudent = ref.watch(userRolePod) == UserRole.student;
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
                  firstPageErrorIndicatorBuilder: (context) =>
                      EnhancedErrorState(
                        title: t.classes.posts.loadError,
                        message: state.error?.toString() ?? '',
                        onRetry: () => pagingController.refresh(),
                      ),
                  noItemsFoundIndicatorBuilder: (context) => EnhancedEmptyState(
                    icon: LucideIcons.messageSquare,
                    title: t.classes.posts.emptyTitle,
                    message: t.classes.posts.emptyDescription,
                    actionLabel: isStudent ? null : t.classes.posts.createFirst,
                    onAction: isStudent ? null : _navigateToCreatePost,
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
                        t.classes.posts.noMore,
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
      floatingActionButton: isStudent
          ? null
          : Semantics(
              label: t.classes.posts.createLabel,
              button: true,
              child: FloatingActionButton.extended(
                onPressed: _navigateToCreatePost,
                icon: const Icon(LucideIcons.plus),
                label: Text(t.classes.posts.newPost),
              ),
            ),
    );
  }
}
