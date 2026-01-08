import 'package:datn_mobile/features/classes/domain/entity/post_entity.dart';
import 'package:datn_mobile/features/classes/ui/widgets/detail/post_type_chip.dart';
import 'package:datn_mobile/features/classes/ui/widgets/posts/post_author_avatar.dart';
import 'package:datn_mobile/features/classes/ui/widgets/posts/post_author_info.dart';
import 'package:datn_mobile/features/classes/ui/widgets/posts/post_options_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Header section of a post card showing author, type, and actions
class PostHeader extends ConsumerWidget {
  final PostEntity post;
  final VoidCallback onTogglePin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PostHeader({
    super.key,
    required this.post,
    required this.onTogglePin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          // Author avatar
          PostAuthorAvatar(authorName: post.authorName),
          const SizedBox(width: 12),

          // Author info and pin indicator
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PostAuthorInfo(
                    authorName: post.authorName,
                    createdAt: post.createdAt,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Post type chip
          PostTypeChip(type: post.type),
          const SizedBox(width: 8),

          // Options menu
          PostOptionsMenu(
            isPinned: post.isPinned,
            onTogglePin: onTogglePin,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}
