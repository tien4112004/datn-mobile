import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/features/classes/domain/entity/attachment_metadata.dart';
import 'package:AIPrimary/features/classes/domain/entity/post_type.dart';
import 'package:AIPrimary/features/classes/domain/entity/linked_resource_entity.dart';
import 'package:AIPrimary/features/classes/states/posts_provider.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/post_actions_section.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/post_editor_section.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/post_options_section.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/post_type_segmented_control.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/attachment_preview_list.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/resource_selector_sheet.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/assignment_selector_sheet.dart';
import 'package:AIPrimary/shared/services/media_service_provider.dart';
import 'package:AIPrimary/shared/widgets/richtext_toolbar.dart';
import 'package:markdown_quill/markdown_quill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:io';

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

  PostType _selectedType = PostType.post;
  bool _allowComments = true;
  DateTime? _dueDate; // For exercise type posts
  final List<AttachmentMetadata> _attachmentMetadata = [];
  final List<LinkedResourceEntity> _linkedResources = [];
  bool _isLoading = true;
  bool _isUploading = false;

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
            _dueDate = post.dueDate;
            _linkedResources.addAll(post.linkedResources);
            // Convert attachment URLs to metadata (without file size info for existing)
            _attachmentMetadata.addAll(
              post.attachments.map(
                (url) => AttachmentMetadata(
                  cdnUrl: url,
                  fileName: url.split('/').last,
                  mediaType: 'image',
                ),
              ),
            );

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

      // Extract CDN URLs from metadata
      final attachmentUrls = _attachmentMetadata.map((m) => m.cdnUrl).toList();

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
              dueDate: _dueDate,
              attachments: attachmentUrls.isEmpty ? null : attachmentUrls,
              linkedResources: _linkedResources.isEmpty
                  ? null
                  : _linkedResources,
            );

        if (mounted) {
          Navigator.of(context).pop(true);
          _showSnackBar(t.classes.postUpsert.updateSuccess, isError: false);
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
              dueDate: _dueDate,
              attachments: attachmentUrls.isEmpty ? null : attachmentUrls,
              linkedResources: _linkedResources.isEmpty
                  ? null
                  : _linkedResources,
            );

        if (mounted) {
          Navigator.of(context).pop(true);
          _showSnackBar(t.classes.postUpsert.createSuccess, isError: false);
        }
      }
    } catch (e) {
      if (mounted) {
        final action = widget.postId != null
            ? t.common.edit.toLowerCase()
            : t.classes.create.toLowerCase();
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

  Future<void> _pickAttachment() async {
    final t = ref.read(translationsPod);
    if (_attachmentMetadata.length >= 10) {
      _showSnackBar(t.classes.postUpsert.maxAttachments);
      return;
    }

    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFiles.isEmpty || !mounted) return;

      setState(() => _isUploading = true);

      final mediaService = ref.read(mediaServiceProvider);

      for (final file in pickedFiles) {
        if (_attachmentMetadata.length >= 10) {
          _showSnackBar(t.classes.postUpsert.maxAttachmentsReached);
          break;
        }

        try {
          // Get file info
          final fileInfo = File(file.path);
          final fileSize = await fileInfo.length();
          final fileName = file.name;

          // Upload file
          final response = await mediaService.uploadMedia(filePath: file.path);

          if (mounted) {
            setState(() {
              _attachmentMetadata.add(
                AttachmentMetadata(
                  cdnUrl: response.cdnUrl,
                  fileName: fileName,
                  fileSize: fileSize,
                  extension: response.extension,
                  mediaType: response.mediaType,
                ),
              );
            });
          }
        } catch (e) {
          if (mounted) {
            _showSnackBar(
              t.classes.postUpsert.uploadError(
                fileName: file.name,
                error: e.toString(),
              ),
            );
          }
        }
      }

      if (mounted) {
        setState(() => _isUploading = false);
        _showSnackBar(
          t.classes.postUpsert.uploadedCount(
            count: pickedFiles.length.toString(),
          ),
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        _showSnackBar(t.classes.postUpsert.pickError(error: e.toString()));
      }
    }
  }

  void _removeAttachment(int index) {
    setState(() => _attachmentMetadata.removeAt(index));
  }

  Future<void> _pickLinkedResource() async {
    final t = ref.read(translationsPod);
    final List<LinkedResourceEntity>? result;

    // Use dedicated assignment sheet for Exercise posts
    if (_selectedType == PostType.exercise) {
      result = await showModalBottomSheet<List<LinkedResourceEntity>>(
        context: context,
        isScrollControlled: true,
        builder: (context) =>
            AssignmentSelectorSheet(alreadySelected: _linkedResources),
      );
    } else {
      // Use general resource selector for other post types
      result = await showModalBottomSheet<List<LinkedResourceEntity>>(
        context: context,
        isScrollControlled: true,
        builder: (context) =>
            ResourceSelectorSheet(alreadySelected: _linkedResources),
      );
    }

    if (result != null && mounted) {
      setState(() {
        _linkedResources.clear();
        _linkedResources.addAll(result!);
      });

      final resourceLabel = _selectedType == PostType.exercise
          ? t.classes.postUpsert.linkedCount(
              count: result.length.toString(),
              resource: t.classes.postActions.assignment(
                count: result.length.toString(),
              ),
            )
          : t.classes.postUpsert.linkedCount(
              count: result.length.toString(),
              resource: t.projects.resource_types.mindmap,
            ); // Simplified for now
      _showSnackBar(resourceLabel, isError: false);
    }
  }

  Future<void> _pickDueDate() async {
    final t = ref.read(translationsPod);
    final now = DateTime.now();
    final initialDate = _dueDate ?? now.add(const Duration(days: 7));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: t.classes.postUpsert.selectDueDate,
    );

    if (pickedDate != null && mounted) {
      setState(() => _dueDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controllerProvider = widget.postId != null
        ? updatePostControllerProvider
        : createPostControllerProvider;
    final controllerState = ref.watch(controllerProvider);
    final isSubmitting =
        controllerState.isLoading || _isLoading || _isUploading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        title: Text(
          widget.postId != null
              ? t.classes.postDialog.editTitle
              : t.classes.postDialog.createTitle,
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
                isSubmitting
                    ? (widget.postId != null
                          ? t.classes.postUpsert.updating
                          : t.classes.postUpsert.creating)
                    : (widget.postId != null
                          ? t.common.save
                          : t.classes.create),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PostTypeSegmentedControl(
                          selectedType: _selectedType,
                          onTypeChanged: isSubmitting
                              ? (_) {}
                              : (type) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedType = type);
                                },
                          // Disable type changes when editing existing posts
                          enabled: !isSubmitting && widget.postId == null,
                        ),
                        // Info message when editing
                        if (widget.postId != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                LucideIcons.info,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  t.classes.postUpsert.typeCannotChange,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Options Section
                  PostOptionsSection(
                    allowComments: _allowComments,
                    selectedType: _selectedType,
                    onAllowCommentsChanged: isSubmitting
                        ? null
                        : (value) {
                            HapticFeedback.selectionClick();
                            setState(() => _allowComments = value);
                          },
                  ),

                  const SizedBox(height: 16),

                  // Due Date Section (Exercise type only)
                  if (_selectedType == PostType.exercise) ...[
                    _buildDueDateSection(theme, colorScheme, isSubmitting, t),
                    const SizedBox(height: 16),
                  ],

                  // Attachments & Actions Section
                  PostActionsSection(
                    selectedType: _selectedType,
                    attachmentsCount: _attachmentMetadata.length,
                    linkedResourcesCount: _linkedResources.length,
                    isLoading: isSubmitting,
                    isUploading: _isUploading,
                    onPickAttachment: _pickAttachment,
                    onPickLinkedResource: _pickLinkedResource,
                  ),

                  const SizedBox(height: 16),

                  // Attachment Preview List (if attachments exist)
                  if (_attachmentMetadata.isNotEmpty)
                    AttachmentPreviewList(
                      attachments: _attachmentMetadata,
                      onRemove: _removeAttachment,
                    ),

                  if (_attachmentMetadata.isNotEmpty)
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

  /// Builds the due date selection section for exercise posts
  Widget _buildDueDateSection(
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDisabled,
    Translations t,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isDisabled ? null : _pickDueDate,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Calendar Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.calendar,
                    size: 20,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),

                // Date Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.classes.postUpsert.dueDate,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _dueDate != null
                            ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                            : t.classes.postUpsert.dueDateHint,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: _dueDate != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                          fontWeight: _dueDate != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
