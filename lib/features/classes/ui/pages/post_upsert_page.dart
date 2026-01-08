import 'package:datn_mobile/features/classes/domain/entity/post_type.dart';
import 'package:datn_mobile/features/classes/states/posts_provider.dart';
import 'package:datn_mobile/features/classes/ui/widgets/posts/post_actions_section.dart';
import 'package:datn_mobile/features/classes/ui/widgets/posts/post_editor_section.dart';
import 'package:datn_mobile/features/classes/ui/widgets/posts/post_options_section.dart';
import 'package:datn_mobile/features/classes/ui/widgets/posts/post_type_segmented_control.dart';
import 'package:datn_mobile/shared/widgets/richtext_toolbar.dart';
import 'package:markdown_quill/markdown_quill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Material 3 post creation/editing page with rich text editor
class PostUpsertPage extends ConsumerStatefulWidget {
  final String classId;
  final String? postId; // Null for create, non-null for edit

  const PostUpsertPage({super.key, required this.classId, this.postId});

  @override
  ConsumerState<PostUpsertPage> createState() => _PostUpsertPageState();
}

class _PostUpsertPageState extends ConsumerState<PostUpsertPage> {
  late quill.QuillController _quillController;
  late FocusNode _editorFocusNode;

  PostType _selectedType = PostType.general;
  bool _allowComments = true;
  DateTime? _scheduledDate;
  final List<String> _attachments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
    _editorFocusNode = FocusNode();
    _initializePost();
  }

  /// Initialize post - fetch existing post if editing, otherwise just mark as loaded
  Future<void> _initializePost() async {
    if (widget.postId != null) {
      try {
        final repository = ref.read(postRepositoryProvider);
        final post = await repository.getPostById(widget.postId!);

        if (mounted) {
          setState(() {
            // Initialize form with post data
            _selectedType = post.type;
            _allowComments = post.allowComments;
            _attachments.addAll(post.attachments);

            // Dispose old controller before creating new one
            _quillController.dispose();

            // Initialize with post content as plain text
            // TODO: Proper markdown to delta conversion can be added later
            _quillController = quill.QuillController.basic();
            _quillController.document.insert(0, post.content);

            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar('Failed to load post: $e');
          Navigator.of(context).pop();
        }
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _editorFocusNode.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Extract plain text from Quill document
    final content = _quillController.document.toPlainText().trim();

    // Validate content
    if (content.isEmpty) {
      _showSnackBar('Please enter post content');
      return;
    }
    if (content.length < 10) {
      _showSnackBar('Content must be at least 10 characters');
      return;
    }

    HapticFeedback.mediumImpact();

    try {
      // Convert Quill document to Markdown for storage
      final delta = _quillController.document.toDelta();
      final converter = DeltaToMarkdown();
      final markdown = converter.convert(delta);

      if (widget.postId != null) {
        // Update existing post
        await ref
            .read(updatePostControllerProvider.notifier)
            .updatePost(
              classId: widget.classId,
              postId: widget.postId!,
              content: markdown,
              type: _selectedType,
              allowComments: _allowComments,
              attachments: _attachments.isEmpty ? null : _attachments,
            );

        if (mounted) {
          Navigator.of(context).pop(true);
          _showSnackBar('Post updated successfully', isError: false);
        }
      } else {
        // Create new post
        await ref
            .read(createPostControllerProvider.notifier)
            .createPost(
              classId: widget.classId,
              content: markdown,
              type: _selectedType,
              allowComments: _allowComments,
              attachments: _attachments.isEmpty ? null : _attachments,
            );

        if (mounted) {
          Navigator.of(context).pop(true);
          _showSnackBar('Post created successfully', isError: false);
        }
      }
    } catch (e) {
      if (mounted) {
        final action = widget.postId != null ? 'update' : 'create';
        _showSnackBar('Failed to $action post: $e');
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledDate ?? now),
      );

      if (time != null && mounted) {
        setState(() {
          _scheduledDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _pickAttachment() async {
    if (mounted) {
      _showSnackBar('Attachment picker coming soon', isError: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controllerProvider = widget.postId != null
        ? updatePostControllerProvider
        : createPostControllerProvider;
    final controllerState = ref.watch(controllerProvider);
    final isSubmitting = controllerState.isLoading || _isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        title: Text(
          widget.postId != null ? 'Edit Post' : 'Create Post',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Schedule button (only for events)
          if (_selectedType == PostType.scheduleEvent)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: isSubmitting ? null : _selectDate,
                icon: const Icon(LucideIcons.calendar),
                tooltip: 'Schedule Post',
                style: IconButton.styleFrom(
                  backgroundColor: _scheduledDate != null
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  foregroundColor: _scheduledDate != null
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),

          // Submit button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: isSubmitting ? null : _handleSubmit,
              icon: isSubmitting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(LucideIcons.check, size: 18),
              label: Text(
                isSubmitting
                    ? (widget.postId != null ? 'Updating...' : 'Creating...')
                    : (widget.postId != null ? 'Update' : 'Create'),
              ),
              style: FilledButton.styleFrom(
                elevation: 0,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Post Type Segmented Control
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PostTypeSegmentedControl(
                      selectedType: _selectedType,
                      onTypeChanged: isSubmitting
                          ? (_) {}
                          : (type) {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedType = type);
                            },
                      enabled: !isSubmitting,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Options Section
                  PostOptionsSection(
                    allowComments: _allowComments,
                    selectedType: _selectedType,
                    scheduledDate: _scheduledDate,
                    onAllowCommentsChanged: isSubmitting
                        ? null
                        : (value) {
                            HapticFeedback.selectionClick();
                            setState(() => _allowComments = value);
                          },
                    onRemoveScheduledDate: () {
                      setState(() => _scheduledDate = null);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Attachments & Actions Section
                  PostActionsSection(
                    selectedType: _selectedType,
                    attachmentsCount: _attachments.length,
                    scheduledDate: _scheduledDate,
                    isLoading: isSubmitting,
                    onPickAttachment: _pickAttachment,
                    onSelectDate: _selectDate,
                  ),

                  const SizedBox(height: 16),

                  // Rich Text Editor
                  PostEditorSection(
                    controller: _quillController,
                    isLoading: isSubmitting,
                    focusNode: _editorFocusNode,
                  ),

                  const SizedBox(height: 100), // Bottom padding for toolbar
                ],
              ),
            ),
          ),

          // Toolbar (only when editor is focused)
          AnimatedBuilder(
            animation: _editorFocusNode,
            builder: (context, child) {
              return AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: _editorFocusNode.hasFocus
                    ? RichTextToolbar(controller: _quillController)
                    : const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }
}
