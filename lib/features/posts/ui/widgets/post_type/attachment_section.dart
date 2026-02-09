import 'package:AIPrimary/features/classes/domain/entity/attachment_metadata.dart';
import 'package:AIPrimary/features/posts/ui/widgets/shared/attachment_preview_list.dart';
import 'package:flutter/material.dart';

/// Attachment preview section for post type posts
class AttachmentSection extends StatelessWidget {
  final List<AttachmentMetadata> attachments;
  final Function(int) onRemove;

  const AttachmentSection({
    super.key,
    required this.attachments,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        AttachmentPreviewList(attachments: attachments, onRemove: onRemove),
        const SizedBox(height: 16),
      ],
    );
  }
}
