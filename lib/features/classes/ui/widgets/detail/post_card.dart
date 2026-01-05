import 'package:datn_mobile/features/classes/domain/entity/post_entity.dart';
import 'package:datn_mobile/features/classes/states/posts_provider.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/comment_section.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/post_edit_dialog.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/post_type_chip.dart';
import 'package:datn_mobile/shared/widgets/themed_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Material 3 card displaying a class post with expandable comments
class PostCard extends ConsumerStatefulWidget {
  final PostEntity post;
  final String classId;

  const PostCard({super.key, required this.post, required this.classId});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool _showComments = false;

  Future<void> _togglePin() async {
    HapticFeedback.mediumImpact();
    try {
      await ref
          .read(updatePostControllerProvider.notifier)
          .togglePin(classId: widget.classId, postId: widget.post.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to toggle pin: $e')));
      }
    }
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post?'),
        content: const Text(
          'This will permanently delete this post and all its comments. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      HapticFeedback.mediumImpact();
      try {
        await ref
            .read(deletePostControllerProvider.notifier)
            .deletePost(classId: widget.classId, postId: widget.post.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete post: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Semantics(
        label:
            '${widget.post.type.displayName} posted ${timeago.format(widget.post.createdAt)}',
        child: ThemedCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              _buildHeader(context, colorScheme),

              // Post content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  widget.post.content,
                  style: theme.textTheme.bodyMedium,
                ),
              ),

              // Footer section
              _buildFooter(context, colorScheme),

              // Comments section (expandable)
              if (_showComments && widget.post.allowComments)
                CommentSection(
                  postId: widget.post.id,
                  allowComments: widget.post.allowComments,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          // Author avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              LucideIcons.user,
              size: 20,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),

          // Author info and timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Teacher', // TODO: Get actual author name
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.post.isPinned) ...[
                      const SizedBox(width: 8),
                      Icon(
                        LucideIcons.pin,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  timeago.format(widget.post.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Post type chip
          PostTypeChip(type: widget.post.type),
          const SizedBox(width: 8),

          // Options menu
          _buildOptionsMenu(context),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          // Comment count button
          if (widget.post.allowComments)
            Semantics(
              label: '${widget.post.commentCount} comments',
              button: true,
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _showComments = !_showComments);
                },
                icon: Icon(
                  _showComments
                      ? LucideIcons.messageSquare
                      : LucideIcons.messageSquare,
                  size: 18,
                ),
                label: Text('${widget.post.commentCount}'),
              ),
            ),

          const Spacer(),

          // Updated indicator
          if (widget.post.updatedAt != widget.post.createdAt)
            Text(
              'Edited',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionsMenu(BuildContext context) {
    return Semantics(
      label: 'Post options',
      button: true,
      child: PopupMenuButton<String>(
        icon: const Icon(LucideIcons.ellipsisVertical, size: 20),
        onSelected: (value) {
          HapticFeedback.selectionClick();
          switch (value) {
            case 'pin':
              _togglePin();
              break;
            case 'edit':
              showDialog(
                context: context,
                builder: (context) =>
                    PostEditDialog(post: widget.post, classId: widget.classId),
              );
              break;
            case 'delete':
              _deletePost();
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'pin',
            child: Row(
              children: [
                Icon(
                  widget.post.isPinned ? LucideIcons.pinOff : LucideIcons.pin,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(widget.post.isPinned ? 'Unpin' : 'Pin'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(LucideIcons.pencil, size: 18),
                SizedBox(width: 12),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(LucideIcons.trash2, size: 18),
                SizedBox(width: 12),
                Text('Delete'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
