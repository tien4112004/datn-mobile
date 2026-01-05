import 'package:datn_mobile/features/classes/states/posts_provider.dart';
import 'package:datn_mobile/features/classes/ui/pages/post_create_page.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/post_card.dart';
import 'package:datn_mobile/shared/widgets/animated_list_item.dart';
import 'package:datn_mobile/shared/widgets/enhanced_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// List of posts with pull-to-refresh and pagination
class PostList extends ConsumerStatefulWidget {
  final String classId;

  const PostList({super.key, required this.classId});

  @override
  ConsumerState<PostList> createState() => _PostListState();
}

class _PostListState extends ConsumerState<PostList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when scrolled to 80%
      final controller = ref.read(
        postsControllerProvider(widget.classId).notifier,
      );
      controller.loadMore();
    }
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await ref.read(postsControllerProvider(widget.classId).notifier).refresh();
  }

  Future<void> _navigateToCreatePost() async {
    HapticFeedback.mediumImpact();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PostCreatePage(classId: widget.classId),
      ),
    );

    // Refresh posts if creation was successful
    if (result == true && mounted) {
      ref.invalidate(postsControllerProvider(widget.classId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsControllerProvider(widget.classId));

    return Scaffold(
      body: postsState.when(
        data: (posts) {
          if (posts.isEmpty) {
            return EnhancedEmptyState(
              icon: LucideIcons.messageSquare,
              title: 'No Posts Yet',
              message: 'Your teacher will post announcements and updates here.',
              actionLabel: 'Create First Post',
              onAction: _navigateToCreatePost,
            );
          }

          // Separate pinned and regular posts
          final pinnedPosts = posts.where((p) => p.isPinned).toList();
          final regularPosts = posts.where((p) => !p.isPinned).toList();

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Pinned posts section
                if (pinnedPosts.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.pin,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pinned',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final post = pinnedPosts[index];
                      return AnimatedListItem(
                        index: index,
                        child: PostCard(
                          key: ValueKey(post.id),
                          post: post,
                          classId: widget.classId,
                        ),
                      );
                    }, childCount: pinnedPosts.length),
                  ),
                  // Divider between pinned and regular
                  SliverToBoxAdapter(
                    child: Divider(
                      height: 32,
                      indent: 16,
                      endIndent: 16,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ],

                // Regular posts section
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final post = regularPosts[index];
                    return AnimatedListItem(
                      index: index + pinnedPosts.length,
                      child: PostCard(
                        key: ValueKey(post.id),
                        post: post,
                        classId: widget.classId,
                      ),
                    );
                  }, childCount: regularPosts.length),
                ),

                // Loading indicator for pagination
                SliverToBoxAdapter(child: _buildPaginationIndicator()),

                // Bottom padding for FAB
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      ref.invalidate(postsControllerProvider(widget.classId)),
                  icon: const Icon(LucideIcons.refreshCw, size: 18),
                  label: const Text('Retry'),
                ),
              ],
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

  Widget _buildPaginationIndicator() {
    final controller = ref.read(
      postsControllerProvider(widget.classId).notifier,
    );

    if (!controller.hasMore) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No more posts',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
