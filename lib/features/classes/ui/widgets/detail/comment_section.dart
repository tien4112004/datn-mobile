import 'package:datn_mobile/features/classes/states/posts_provider.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/comment_card.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/comment_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Section displaying comments for a post with input field
class CommentSection extends ConsumerWidget {
  final String postId;
  final bool allowComments;

  const CommentSection({
    super.key,
    required this.postId,
    this.allowComments = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final commentsState = ref.watch(commentsControllerProvider(postId));

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        children: [
          // Comments list
          commentsState.when(
            data: (comments) {
              if (comments.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.messageSquare,
                        size: 48,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No comments yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        allowComments
                            ? 'Be the first to comment!'
                            : 'Comments are disabled for this post',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: comments.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 56,
                  color: colorScheme.outlineVariant,
                ),
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return CommentCard(
                    key: ValueKey(comment.id),
                    comment: comment,
                    canDelete: true, // TODO: Check user permissions
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.circleAlert,
                    size: 48,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load comments',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    error.toString(),
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () =>
                        ref.invalidate(commentsControllerProvider(postId)),
                    icon: const Icon(LucideIcons.refreshCw, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),

          // Comment input
          if (allowComments)
            CommentInput(postId: postId, enabled: allowComments),
        ],
      ),
    );
  }
}
