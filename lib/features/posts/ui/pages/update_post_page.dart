import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/features/classes/domain/entity/post_type.dart';
import 'package:AIPrimary/features/classes/states/posts_provider.dart';
import 'package:AIPrimary/features/posts/ui/widgets/shared/post_editor_section.dart';
import 'package:AIPrimary/features/posts/ui/widgets/shared/post_options_section.dart';
import 'package:AIPrimary/shared/widgets/richtext_toolbar.dart';
import 'package:markdown_quill/markdown_quill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Material 3 post update page - text-only editing
class UpdatePostPage extends ConsumerStatefulWidget {
  final String classId;
  final String postId;

  const UpdatePostPage({
    super.key,
    required this.classId,
    required this.postId,
  });

  @override
  ConsumerState<UpdatePostPage> createState() => _UpdatePostPageState();
}

class _UpdatePostPageState extends ConsumerState<UpdatePostPage> {
  late quill.QuillController _quillController;
  late FocusNode _editorFocusNode;

  PostType? _selectedType;
  bool _allowComments = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
    _editorFocusNode = FocusNode();
    _initializePost();
  }

  /// Initialize post - fetch existing post for editing
  Future<void> _initializePost() async {
    try {
      final repository = ref.read(postRepositoryProvider);
      final post = await repository.getPostById(widget.postId);

      if (mounted) {
        setState(() {
          // Initialize form with post data
          _selectedType = post.type;
          _allowComments = post.allowComments;

          // Dispose old controller before creating new one
          _quillController.dispose();

          // Initialize with post content as plain text
          _quillController = quill.QuillController.basic();
          _quillController.document.insert(0, post.content);

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          context.mounted
              ? ref
                    .read(translationsPod)
                    .classes
                    .postUpsert
                    .loadError(error: e.toString())
              : 'Failed to load post: $e',
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _editorFocusNode.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final t = ref.read(translationsPod);
    // Extract plain text from Quill document
    final content = _quillController.document.toPlainText().trim();

    // Validate content
    if (content.isEmpty) {
      _showSnackBar(t.classes.postDialog.contentRequired);
      return;
    }
    if (content.length < 10) {
      _showSnackBar(t.classes.postDialog.contentMinLength);
      return;
    }

    HapticFeedback.mediumImpact();

    try {
      // Convert Quill document to Markdown for storage
      final delta = _quillController.document.toDelta();
      final converter = DeltaToMarkdown();
      final markdown = converter.convert(delta);

      // Update existing post (only content and allowComments)
      await ref
          .read(updatePostControllerProvider.notifier)
          .updatePost(
            classId: widget.classId,
            postId: widget.postId,
            content: markdown,
            type: _selectedType!,
            allowComments: _allowComments,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        _showSnackBar(t.classes.postUpsert.updateSuccess, isError: false);
      }
    } catch (e) {
      if (mounted) {
        final action = t.common.edit.toLowerCase();
        _showSnackBar(
          t.classes.postUpsert.actionError(action: action, error: e.toString()),
        );
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

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controllerState = ref.watch(updatePostControllerProvider);
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
          t.classes.postDialog.editTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
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
                isSubmitting ? t.classes.postUpsert.updating : t.common.save,
              ),
              style: FilledButton.styleFrom(
                elevation: 0,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Type info badge (read-only)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _selectedType == PostType.exercise
                                          ? LucideIcons.clipboardList
                                          : LucideIcons.messageSquare,
                                      size: 20,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _selectedType == PostType.exercise
                                          ? 'Exercise Post'
                                          : 'Regular Post',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Options Section
                        PostOptionsSection(
                          allowComments: _allowComments,
                          selectedType: _selectedType ?? PostType.post,
                          onAllowCommentsChanged: isSubmitting
                              ? null
                              : (value) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _allowComments = value);
                                },
                        ),

                        const SizedBox(height: 16),

                        // Rich Text Editor
                        PostEditorSection(
                          controller: _quillController,
                          isLoading: isSubmitting,
                          focusNode: _editorFocusNode,
                        ),

                        const SizedBox(
                          height: 100,
                        ), // Bottom padding for toolbar
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
