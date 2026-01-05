import 'dart:convert';

import 'package:datn_mobile/features/classes/domain/entity/post_type.dart';
import 'package:datn_mobile/features/classes/states/posts_provider.dart';
import 'package:datn_mobile/features/classes/ui/pages/widgets/post_actions_section.dart';
import 'package:datn_mobile/features/classes/ui/pages/widgets/post_editor_section.dart';
import 'package:datn_mobile/features/classes/ui/pages/widgets/post_options_section.dart';
import 'package:datn_mobile/features/classes/ui/pages/widgets/post_type_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Material 3 post creation page with rich text editor
class PostCreatePage extends ConsumerStatefulWidget {
  final String classId;

  const PostCreatePage({super.key, required this.classId});

  @override
  ConsumerState<PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends ConsumerState<PostCreatePage> {
  late quill.QuillController _quillController;
  late FocusNode _editorFocusNode;
  bool _isEditorFocused = false;

  PostType _selectedType = PostType.general;
  bool _allowComments = true;
  DateTime? _scheduledDate;
  final List<String> _attachments = [];

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
    _editorFocusNode = FocusNode();
    _editorFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _editorFocusNode.removeListener(_onFocusChange);
    _editorFocusNode.dispose();
    _quillController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isEditorFocused = _editorFocusNode.hasFocus;
    });
  }

  Future<void> _handleCreate() async {
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
      // Convert Quill document to JSON for storage (preserves formatting)
      final documentJson = jsonEncode(
        _quillController.document.toDelta().toJson(),
      );

      await ref
          .read(createPostControllerProvider.notifier)
          .createPost(
            classId: widget.classId,
            content: documentJson, // Store as JSON to preserve formatting
            type: _selectedType,
            allowComments: _allowComments,
            attachments: _attachments.isEmpty ? null : _attachments,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        _showSnackBar('Post created successfully', isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to create post: $e');
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
    // TODO: Implement file picker and upload
    if (mounted) {
      _showSnackBar('Attachment picker coming soon', isError: false);
    }
  }

  void _showPostTypeMenu() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.layoutList,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Post Type',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Post type options
            PostTypeOption(
              icon: LucideIcons.messageCircle,
              label: 'General Post',
              description: 'Share updates and information',
              isSelected: _selectedType == PostType.general,
              onTap: () {
                setState(() => _selectedType = PostType.general);
                Navigator.pop(context);
                HapticFeedback.selectionClick();
              },
            ),
            PostTypeOption(
              icon: LucideIcons.megaphone,
              label: 'Announcement',
              description: 'Important class updates',
              isSelected: _selectedType == PostType.announcement,
              onTap: () {
                setState(() => _selectedType = PostType.announcement);
                Navigator.pop(context);
                HapticFeedback.selectionClick();
              },
            ),
            PostTypeOption(
              icon: LucideIcons.calendar,
              label: 'Scheduled Event',
              description: 'Create an event with date',
              isSelected: _selectedType == PostType.scheduleEvent,
              onTap: () {
                setState(() => _selectedType = PostType.scheduleEvent);
                Navigator.pop(context);
                HapticFeedback.selectionClick();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final createState = ref.watch(createPostControllerProvider);
    final isLoading = createState.isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        title: Text(
          'Create Post',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Post type selector button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: isLoading ? null : _showPostTypeMenu,
              icon: Icon(_getPostTypeIcon()),
              tooltip: 'Post Type: ${_getPostTypeLabel()}',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          // Create button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: isLoading ? null : _handleCreate,
              icon: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(LucideIcons.check, size: 18),
              label: Text(isLoading ? 'Creating...' : 'Create'),
              style: FilledButton.styleFrom(
                elevation: 0,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content (doesn't resize when keyboard appears)
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: _isEditorFocused
                    ? MediaQuery.of(context).viewInsets.bottom + 56
                    : 0,
              ),
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight,
                child: Column(
                  children: [
                    // Options Section
                    PostOptionsSection(
                      allowComments: _allowComments,
                      selectedType: _selectedType,
                      scheduledDate: _scheduledDate,
                      onAllowCommentsChanged: isLoading
                          ? null
                          : (value) {
                              HapticFeedback.selectionClick();
                              setState(() => _allowComments = value);
                            },
                      onRemoveScheduledDate: () {
                        setState(() => _scheduledDate = null);
                      },
                    ),

                    // Attachments & Date Section
                    PostActionsSection(
                      selectedType: _selectedType,
                      attachmentsCount: _attachments.length,
                      scheduledDate: _scheduledDate,
                      isLoading: isLoading,
                      onPickAttachment: _pickAttachment,
                      onSelectDate: _selectDate,
                    ),

                    // Rich Text Editor (takes remaining space)
                    Expanded(
                      child: PostEditorSection(
                        controller: _quillController,
                        isLoading: isLoading,
                        focusNode: _editorFocusNode,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Toolbar overlay (only visible when editor is focused, appears above keyboard)
          if (_isEditorFocused)
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).viewInsets.bottom,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: quill.QuillSimpleToolbar(
                    controller: _quillController,
                    config: quill.QuillSimpleToolbarConfig(
                      showAlignmentButtons: false,
                      showBackgroundColorButton: false,
                      showCenterAlignment: false,
                      showClipboardCopy: false,
                      showClipboardCut: false,
                      showClipboardPaste: false,
                      showCodeBlock: false,
                      showColorButton: false,
                      showDirection: false,
                      showDividers: true,
                      showHeaderStyle: true,
                      showInlineCode: false,
                      showIndent: false,
                      showJustifyAlignment: false,
                      showLeftAlignment: false,
                      showLink: true,
                      showListBullets: true,
                      showListCheck: false,
                      showListNumbers: true,
                      showQuote: true,
                      showRedo: true,
                      showRightAlignment: false,
                      showSearchButton: false,
                      showSmallButton: false,
                      showStrikeThrough: true,
                      showSubscript: false,
                      showSuperscript: false,
                      showUnderLineButton: true,
                      showUndo: true,
                      buttonOptions: quill.QuillSimpleToolbarButtonOptions(
                        base: quill.QuillToolbarBaseButtonOptions(
                          iconTheme: quill.QuillIconTheme(
                            iconButtonSelectedData: quill.IconButtonData(
                              color: colorScheme.primary,
                              focusColor: colorScheme.primary,
                              hoverColor: colorScheme.primary,
                              highlightColor: colorScheme.primary,
                              splashColor: colorScheme.primary,
                              disabledColor: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getPostTypeIcon() {
    switch (_selectedType) {
      case PostType.general:
        return LucideIcons.messageCircle;
      case PostType.announcement:
        return LucideIcons.megaphone;
      case PostType.scheduleEvent:
        return LucideIcons.calendar;
    }
  }

  String _getPostTypeLabel() {
    switch (_selectedType) {
      case PostType.general:
        return 'General Post';
      case PostType.announcement:
        return 'Announcement';
      case PostType.scheduleEvent:
        return 'Event';
    }
  }
}
