import 'package:AIPrimary/features/classes/states/posts_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Action buttons for comment (delete)
class CommentActions extends ConsumerWidget {
  final String postId;
  final String commentId;
  final bool canDelete;

  const CommentActions({
    super.key,
    required this.postId,
    required this.commentId,
    required this.canDelete,
  });

  Future<void> _deleteComment(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment?'),
        content: const Text('This action cannot be undone.'),
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

    if (confirmed == true && context.mounted) {
      HapticFeedback.mediumImpact();
      try {
        await ref
            .read(deleteCommentControllerProvider.notifier)
            .deleteComment(postId: postId, commentId: commentId);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete comment: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!canDelete) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Delete comment',
      button: true,
      child: IconButton(
        onPressed: () => _deleteComment(context, ref),
        icon: Icon(LucideIcons.trash2, size: 16, color: colorScheme.error),
      ),
    );
  }
}
