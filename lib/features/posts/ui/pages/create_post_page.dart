import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/features/classes/domain/entity/attachment_metadata.dart';
import 'package:AIPrimary/features/classes/domain/entity/post_type.dart';
import 'package:AIPrimary/features/classes/domain/entity/linked_resource_entity.dart';
import 'package:AIPrimary/features/classes/states/posts_provider.dart';
import 'package:AIPrimary/features/posts/ui/widgets/shared/post_options_section.dart';
import 'package:AIPrimary/features/posts/ui/widgets/shared/post_type_segmented_control.dart';
import 'package:AIPrimary/features/posts/ui/widgets/shared/resource_selector_sheet.dart';
import 'package:AIPrimary/features/posts/ui/widgets/shared/assignment_selector_sheet.dart';
import 'package:AIPrimary/features/posts/ui/widgets/post_type/post_typed_tab.dart';
import 'package:AIPrimary/features/posts/ui/widgets/exercise_type/exercise_typed_tab.dart';
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

/// Material 3 post creation page with rich text editor
class CreatePostPage extends ConsumerStatefulWidget {
  final String classId;

  const CreatePostPage({super.key, required this.classId});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  late quill.QuillController _quillController;
  late FocusNode _editorFocusNode;

  // Common state
  PostType _selectedType = PostType.post;
  bool _allowComments = true;
  final List<AttachmentMetadata> _attachmentMetadata = [];
  final List<LinkedResourceEntity> _linkedResources = [];
  bool _isUploading = false;

  // Exercise-specific state
  DateTime? _dueDate;
  String? _selectedAssignmentId;
  int? _maxSubmissions;
  bool _allowRetake = true;
  bool _showCorrectAnswers = true;
  bool _showScoreImmediately = false;
  double? _passingScore;
  DateTime? _availableFrom;
  DateTime? _availableUntil;

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
    _editorFocusNode = FocusNode();
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
            linkedResources: _linkedResources.isEmpty ? null : _linkedResources,
            // Assignment-specific fields (for exercise posts)
            assignmentId: _selectedType == PostType.exercise
                ? _selectedAssignmentId
                : null,
            maxSubmissions: _selectedType == PostType.exercise
                ? _maxSubmissions
                : null,
            allowRetake: _selectedType == PostType.exercise
                ? _allowRetake
                : null,
            showCorrectAnswers: _selectedType == PostType.exercise
                ? _showCorrectAnswers
                : null,
            showScoreImmediately: _selectedType == PostType.exercise
                ? _showScoreImmediately
                : null,
            passingScore: _selectedType == PostType.exercise
                ? _passingScore
                : null,
            availableFrom: _selectedType == PostType.exercise
                ? _availableFrom
                : null,
            availableUntil: _selectedType == PostType.exercise
                ? _availableUntil
                : null,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        _showSnackBar(t.classes.postUpsert.createSuccess, isError: false);
      }
    } catch (e) {
      if (mounted) {
        final action = t.classes.create.toLowerCase();
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

  Future<void> _pickAssignment() async {
    // Show assignment selector
    final result = await showModalBottomSheet<LinkedResourceEntity>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AssignmentSelectorSheet(
        alreadySelected: [],
        singleSelect: true,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedAssignmentId = result.id;
      });
    }
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
            );
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
    final controllerState = ref.watch(createPostControllerProvider);
    final isSubmitting = controllerState.isLoading || _isUploading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        title: Text(
          t.classes.postDialog.createTitle,
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
                isSubmitting ? t.classes.postUpsert.creating : t.classes.create,
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
                    onAllowCommentsChanged: isSubmitting
                        ? null
                        : (value) {
                            HapticFeedback.selectionClick();
                            setState(() => _allowComments = value);
                          },
                  ),

                  const SizedBox(height: 16),

                  // Type-specific tab content
                  if (_selectedType == PostType.post)
                    PostTypedTab(
                      quillController: _quillController,
                      editorFocusNode: _editorFocusNode,
                      isSubmitting: isSubmitting,
                      isUploading: _isUploading,
                      attachmentMetadata: _attachmentMetadata,
                      linkedResourcesCount: _linkedResources.length,
                      onPickAttachment: _pickAttachment,
                      onPickLinkedResource: _pickLinkedResource,
                      onRemoveAttachment: _removeAttachment,
                    )
                  else
                    ExerciseTypedTab(
                      quillController: _quillController,
                      editorFocusNode: _editorFocusNode,
                      isSubmitting: isSubmitting,
                      dueDate: _dueDate,
                      selectedAssignmentId: _selectedAssignmentId,
                      maxSubmissions: _maxSubmissions,
                      passingScore: _passingScore,
                      allowRetake: _allowRetake,
                      showCorrectAnswers: _showCorrectAnswers,
                      showScoreImmediately: _showScoreImmediately,
                      linkedResourcesCount: _linkedResources.length,
                      onPickDueDate: _pickDueDate,
                      onPickAssignment: _pickAssignment,
                      onPickLinkedResource: _pickLinkedResource,
                      onMaxSubmissionsChanged: (value) =>
                          setState(() => _maxSubmissions = value),
                      onPassingScoreChanged: (value) =>
                          setState(() => _passingScore = value),
                      onAllowRetakeChanged: (value) =>
                          setState(() => _allowRetake = value),
                      onShowCorrectAnswersChanged: (value) =>
                          setState(() => _showCorrectAnswers = value),
                      onShowScoreImmediatelyChanged: (value) =>
                          setState(() => _showScoreImmediately = value),
                      translations: t,
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
