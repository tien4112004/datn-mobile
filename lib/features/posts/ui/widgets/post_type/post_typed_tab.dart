import 'package:AIPrimary/features/classes/domain/entity/attachment_metadata.dart';
import 'package:AIPrimary/features/classes/domain/entity/post_type.dart';
import 'package:AIPrimary/features/posts/ui/widgets/shared/post_editor_section.dart';
import 'package:AIPrimary/features/posts/ui/widgets/shared/post_actions_section.dart';
import 'package:AIPrimary/features/posts/ui/widgets/post_type/attachment_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

/// Post type tab widget combining editor, actions, and attachments
class PostTypedTab extends StatelessWidget {
  final quill.QuillController quillController;
  final FocusNode editorFocusNode;
  final bool isSubmitting;
  final bool isUploading;
  final List<AttachmentMetadata> attachmentMetadata;
  final int linkedResourcesCount;
  final VoidCallback onPickAttachment;
  final VoidCallback onPickLinkedResource;
  final Function(int) onRemoveAttachment;

  const PostTypedTab({
    super.key,
    required this.quillController,
    required this.editorFocusNode,
    required this.isSubmitting,
    required this.isUploading,
    required this.attachmentMetadata,
    required this.linkedResourcesCount,
    required this.onPickAttachment,
    required this.onPickLinkedResource,
    required this.onRemoveAttachment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Attachments & Actions Section
        PostActionsSection(
          selectedType: PostType.post,
          attachmentsCount: attachmentMetadata.length,
          linkedResourcesCount: linkedResourcesCount,
          isLoading: isSubmitting,
          isUploading: isUploading,
          onPickAttachment: onPickAttachment,
          onPickLinkedResource: onPickLinkedResource,
        ),
        const SizedBox(height: 16),

        // Attachment Preview List (if attachments exist)
        AttachmentSection(
          attachments: attachmentMetadata,
          onRemove: onRemoveAttachment,
        ),

        // Rich Text Editor
        PostEditorSection(
          controller: quillController,
          isLoading: isSubmitting,
          focusNode: editorFocusNode,
        ),
      ],
    );
  }
}
