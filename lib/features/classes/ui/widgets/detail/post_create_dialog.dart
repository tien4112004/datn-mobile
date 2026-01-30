import 'package:AIPrimary/features/classes/domain/entity/post_type.dart';
import 'package:AIPrimary/features/classes/states/posts_provider.dart';
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
          const SnackBar(content: Text('Post created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create post: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final createState = ref.watch(createPostControllerProvider);

    return AlertDialog(
      title: const Text('Create Post'),
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
                    value: PostType.post,
                    label: Text('Post'),
                    icon: Icon(LucideIcons.messageCircle, size: 16),
                  ),
                  ButtonSegment(
                    value: PostType.exercise,
                    label: Text('Exercise'),
                    icon: Icon(LucideIcons.clipboardList, size: 16),
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
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: createState.isLoading ? null : _handleCreate,
          child: createState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
