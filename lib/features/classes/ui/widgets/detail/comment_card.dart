import 'package:AIPrimary/features/auth/controllers/user_controller.dart';
import 'package:AIPrimary/features/classes/domain/entity/comment_entity.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/comment_actions.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/comment_author_info.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/comment_avatar.dart';
import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Card displaying an individual comment
class CommentCard extends ConsumerWidget {
  final CommentEntity comment;

  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userState = ref.watch(userControllerProvider);

    // Determine author name and if current user
    final currentUserId = userState.value?.email;
    final isCurrentUser =
        currentUserId != null && comment.userId == currentUserId;
    final authorName = comment.authorName ?? 'User';

    // Check if user can delete this comment
    // User can delete if: 1) it's their own comment, or 2) they are a teacher
    final canDelete = isCurrentUser || (userState.value?.role == null);

    return Semantics(
      label:
          'Comment by $authorName, posted ${timeago.format(comment.createdAt ?? DateFormatHelper.getNow())}',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CommentAvatar(
              avatarUrl: comment.authorAvatarUrl,
              authorName: authorName,
            ),
            const SizedBox(width: 12),
            // Comment content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  comment.createdAt != null
                      ? CommentAuthorInfo(
                          authorName: authorName,
                          createdAt: comment.createdAt!,
                          isCurrentUser: isCurrentUser,
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 4),
                  Text(comment.content, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            // Delete button
            const SizedBox(width: 8),
            CommentActions(
              postId: comment.postId,
              commentId: comment.id,
              canDelete: canDelete,
            ),
          ],
        ),
      ),
    );
  }
}
