import 'package:datn_mobile/features/classes/domain/entity/post_entity.dart';
import 'package:datn_mobile/features/classes/domain/entity/post_type.dart';
import 'package:datn_mobile/features/classes/states/posts_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Dialog for editing an existing post with Material 3 design
class PostEditDialog extends ConsumerStatefulWidget {
  final PostEntity post;
  final String classId;

  const PostEditDialog({super.key, required this.post, required this.classId});

  @override
  ConsumerState<PostEditDialog> createState() => _PostEditDialogState();
}

class _PostEditDialogState extends ConsumerState<PostEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;

  late PostType _selectedType;
  late bool _allowComments;
  late bool _isPinned;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
    _selectedType = widget.post.type;
    _allowComments = widget.post.allowComments;
    _isPinned = widget.post.isPinned;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();

    try {
      await ref
          .read(updatePostControllerProvider.notifier)
          .updatePost(
            classId: widget.classId,
            postId: widget.post.id,
            content: _contentController.text.trim(),
            type: _selectedType,
            allowComments: _allowComments,
            isPinned: _isPinned,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update post: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final updateState = ref.watch(updatePostControllerProvider);

    return AlertDialog(
      title: Row(
        children: [
          const Expanded(child: Text('Edit Post')),
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 20),
            color: colorScheme.error,
            onPressed: updateState.isLoading ? null : () => _handleDelete(),
            tooltip: 'Delete post',
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post type selector
              Text(
                'Type',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<PostType>(
                segments: const [
                  ButtonSegment(
                    value: PostType.general,
                    label: Text('Post'),
                    icon: Icon(LucideIcons.messageCircle, size: 16),
                  ),
                  ButtonSegment(
                    value: PostType.announcement,
                    label: Text('Announce'),
                    icon: Icon(LucideIcons.megaphone, size: 16),
                  ),
                  ButtonSegment(
                    value: PostType.scheduleEvent,
                    label: Text('Event'),
                    icon: Icon(LucideIcons.calendar, size: 16),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<PostType> newSelection) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedType = newSelection.first);
                },
              ),
              const SizedBox(height: 16),

              // Content field
              Text(
                'Content',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'What would you like to share?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter some content';
                  }
                  if (value.trim().length < 10) {
                    return 'Content must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Pin toggle
              SwitchListTile(
                value: _isPinned,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() => _isPinned = value);
                },
                title: const Text('Pin post'),
                subtitle: const Text('Show this post at the top'),
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(LucideIcons.pin),
              ),

              // Allow comments toggle
              SwitchListTile(
                value: _allowComments,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() => _allowComments = value);
                },
                title: const Text('Allow comments'),
                subtitle: const Text('Let others comment on this post'),
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(LucideIcons.messageSquare),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: updateState.isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: updateState.isLoading ? null : _handleUpdate,
          child: updateState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _handleDelete() async {
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

        if (mounted) {
          Navigator.of(context).pop(); // Close edit dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete post: $e')));
        }
      }
    }
  }
}
