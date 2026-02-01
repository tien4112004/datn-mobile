import 'package:AIPrimary/features/classes/domain/entity/post_type.dart';
import 'package:AIPrimary/features/classes/states/posts_provider.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Dialog for creating a new post with Material 3 design
class PostCreateDialog extends ConsumerStatefulWidget {
  final String classId;

  const PostCreateDialog({super.key, required this.classId});

  @override
  ConsumerState<PostCreateDialog> createState() => _PostCreateDialogState();
}

class _PostCreateDialogState extends ConsumerState<PostCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  PostType _selectedType = PostType.post;
  bool _allowComments = true;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    final t = ref.read(translationsPod);
    HapticFeedback.mediumImpact();

    try {
      await ref
          .read(createPostControllerProvider.notifier)
          .createPost(
            classId: widget.classId,
            content: _contentController.text.trim(),
            type: _selectedType,
            allowComments: _allowComments,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.classes.postDialog.createSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.classes.postDialog.createError(error: e.toString()),
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
    final createState = ref.watch(createPostControllerProvider);

    return AlertDialog(
      title: Text(t.classes.postDialog.createTitle),
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
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: createState.isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: Text(t.classes.cancel),
        ),
        FilledButton(
          onPressed: createState.isLoading ? null : _handleCreate,
          child: createState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(t.classes.create),
        ),
      ],
    );
  }
}
