import 'package:datn_mobile/features/classes/states/posts_provider.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/comment_empty_state.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/comment_error_state.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/comment_input.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/comment_list.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/comment_loading_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                return CommentEmptyState(allowComments: allowComments);
              }
              return CommentList(comments: comments);
            },
            loading: () => const CommentLoadingState(),
            error: (error, stack) => CommentErrorState(
              error: error,
              onRetry: () => ref.invalidate(commentsControllerProvider(postId)),
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
