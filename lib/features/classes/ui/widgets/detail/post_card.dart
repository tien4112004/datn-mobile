import 'package:AIPrimary/features/auth/domain/entities/user_role.dart';
import 'package:AIPrimary/features/classes/domain/entity/class_entity.dart';
import 'package:AIPrimary/features/classes/domain/entity/post_entity.dart';
import 'package:AIPrimary/features/classes/states/posts_provider.dart';
import 'package:AIPrimary/features/classes/ui/pages/post_upsert_page.dart';
import 'package:AIPrimary/features/classes/ui/widgets/detail/comment_section.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/post_content.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/post_footer.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/post_header.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/post_pin_indicator.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/post_attachments_display.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/linked_resources_display.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:AIPrimary/shared/widgets/themed_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Material 3 card displaying a class post with expandable comments
class PostCard extends ConsumerStatefulWidget {
  final PostEntity post;
  final ClassEntity classEntity;

  const PostCard({super.key, required this.post, required this.classEntity});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool _showComments = false;

  Future<void> _togglePin() async {
    HapticFeedback.mediumImpact();
    final t = ref.read(translationsPod);
    try {
      await ref
          .read(updatePostControllerProvider.notifier)
          .togglePin(
            classId: widget.classEntity.id,
            postId: widget.post.id,
            pinned: !widget.post.isPinned,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.classes.posts.pinError(error: e.toString())),
          ),
        );
      }
    }
  }

  Future<void> _deletePost() async {
    final t = ref.read(translationsPod);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.classes.posts.deleteTitle),
        content: Text(t.classes.posts.deleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.classes.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(t.classes.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      HapticFeedback.mediumImpact();
      try {
        await ref
            .read(deletePostControllerProvider.notifier)
            .deletePost(classId: widget.classEntity.id, postId: widget.post.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.classes.posts.deleteError(error: e.toString())),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final isStudent = ref.watch(userRolePod) == UserRole.student;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRect(
        clipBehavior: Clip.none,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Semantics(
              label: t.classes.posts.semanticLabel(
                postType: widget.post.type.displayName,
                timeAgo: timeago.format(widget.post.createdAt),
              ),
              child: ThemedCard(
                borderColor: widget.post.isPinned
                    ? widget.classEntity.headerColor
                    : null,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    PostHeader(
                      post: widget.post,
                      onTogglePin: isStudent ? null : _togglePin,
                      onEdit: isStudent
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PostUpsertPage(
                                    classId: widget.classEntity.id,
                                    postId: widget.post.id,
                                  ),
                                ),
                              );
                            },
                      onDelete: isStudent ? null : _deletePost,
                    ),

                    // Post content
                    PostContent(content: widget.post.content),

                    // Attachments (if any)
                    if (widget.post.attachments.isNotEmpty)
                      PostAttachmentsDisplay(
                        attachments: widget.post.attachments,
                      ),

                    // Linked Resources (if any)
                    if (widget.post.linkedResources.isNotEmpty)
                      LinkedResourcesDisplay(
                        linkedResources: widget.post.linkedResources,
                      ),

                    // Footer section
                    PostFooter(
                      allowComments: widget.post.allowComments,
                      commentCount: widget.post.commentCount,
                      showComments: _showComments,
                      onToggleComments: () =>
                          setState(() => _showComments = !_showComments),
                      createdAt: widget.post.createdAt,
                      updatedAt: widget.post.updatedAt,
                    ),

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
            // Pinned Indicator (rendered last to appear on top)
            if (widget.post.isPinned)
              Positioned(
                top: -3,
                left: -12,
                child: Transform.rotate(
                  angle: -0.8,
                  child: PostPinIndicator(
                    isPinned: widget.post.isPinned,
                    color: widget.classEntity.headerColor,
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
