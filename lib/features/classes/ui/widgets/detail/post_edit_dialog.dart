import 'package:AIPrimary/features/classes/domain/entity/post_entity.dart';
import 'package:AIPrimary/features/classes/domain/entity/post_type.dart';
import 'package:AIPrimary/features/classes/states/posts_provider.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
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

    final t = ref.read(translationsPod);
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
          SnackBar(content: Text(t.classes.postDialog.updateSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.classes.postDialog.updateError(error: e.toString()),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);
    final updateState = ref.watch(updatePostControllerProvider);

    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(t.classes.postDialog.editTitle)),
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 20),
            color: colorScheme.error,
            onPressed: updateState.isLoading ? null : () => _handleDelete(),
            tooltip: t.classes.postDialog.deleteTooltip,
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
                t.classes.postDialog.typeLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<PostType>(
                segments: [
                  ButtonSegment(
                    value: PostType.post,
                    label: Text(t.classes.postDialog.postType),
                    icon: const Icon(LucideIcons.messageCircle, size: 16),
                  ),
                  ButtonSegment(
                    value: PostType.exercise,
                    label: Text(t.classes.postDialog.exerciseType),
                    icon: const Icon(LucideIcons.clipboardList, size: 16),
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
                t.classes.postDialog.contentLabel,
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
                  hintText: t.classes.postDialog.contentHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t.classes.postDialog.contentRequired;
                  }
                  if (value.trim().length < 10) {
                    return t.classes.postDialog.contentMinLength;
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
                title: Text(t.classes.postDialog.pinPost),
                subtitle: Text(t.classes.postDialog.pinPostDesc),
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
                title: Text(t.classes.postDialog.allowComments),
                subtitle: Text(t.classes.postDialog.allowCommentsDesc),
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
          child: Text(t.classes.cancel),
        ),
        FilledButton(
          onPressed: updateState.isLoading ? null : _handleUpdate,
          child: updateState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(t.classes.update),
        ),
      ],
    );
  }

  Future<void> _handleDelete() async {
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
            .deletePost(classId: widget.classId, postId: widget.post.id);

        if (mounted) {
          Navigator.of(context).pop(); // Close edit dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.classes.postDialog.deleteSuccess)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                t.classes.postDialog.deleteError(error: e.toString()),
              ),
            ),
          );
        }
      }
    }
  }
}
