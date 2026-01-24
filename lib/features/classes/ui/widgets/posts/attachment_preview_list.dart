import 'package:cached_network_image/cached_network_image.dart';
import 'package:datn_mobile/features/classes/domain/entity/attachment_metadata.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Enhanced preview list showing file metadata for attachments
class AttachmentPreviewList extends StatelessWidget {
  final List<AttachmentMetadata> attachments;
  final void Function(int index) onRemove;

  const AttachmentPreviewList({
    super.key,
    required this.attachments,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.paperclip,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Attachments (${attachments.length}/10)',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...attachments.asMap().entries.map((entry) {
            final index = entry.key;
            final attachment = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildAttachmentTile(
                context,
                theme,
                colorScheme,
                attachment,
                index,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAttachmentTile(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AttachmentMetadata attachment,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          // Thumbnail or Icon
          if (attachment.isImage)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: attachment.cdnUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: colorScheme.surfaceContainerHigh,
                  child: Icon(
                    LucideIcons.image,
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: colorScheme.errorContainer,
                  child: Icon(
                    LucideIcons.imageOff,
                    color: colorScheme.onErrorContainer,
                    size: 24,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.file,
                color: colorScheme.primary,
                size: 24,
              ),
            ),

          const SizedBox(width: 12),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (attachment.extension != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          attachment.extension!.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(
                      LucideIcons.hardDrive,
                      size: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      attachment.fileSizeFormatted,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Remove button
          IconButton(
            onPressed: () => onRemove(index),
            icon: Icon(LucideIcons.x, color: colorScheme.error, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.errorContainer.withValues(
                alpha: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
