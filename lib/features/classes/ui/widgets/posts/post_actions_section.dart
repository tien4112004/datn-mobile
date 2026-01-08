import 'package:datn_mobile/features/classes/domain/entity/post_type.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Actions section for attachments and event date selection
class PostActionsSection extends StatelessWidget {
  final PostType selectedType;
  final int attachmentsCount;
  final DateTime? scheduledDate;
  final bool isLoading;
  final VoidCallback onPickAttachment;
  final VoidCallback onSelectDate;

  const PostActionsSection({
    super.key,
    required this.selectedType,
    required this.attachmentsCount,
    required this.scheduledDate,
    required this.isLoading,
    required this.onPickAttachment,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Attachments button
          Expanded(
            flex: attachmentsCount > 0 ? 7 : 1,
            child: OutlinedButton(
              onPressed: isLoading ? null : onPickAttachment,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                side: BorderSide(
                  color: attachmentsCount > 0
                      ? colorScheme.primary.withValues(alpha: 0.3)
                      : colorScheme.outlineVariant,
                ),
                backgroundColor: attachmentsCount > 0
                    ? colorScheme.primaryContainer.withValues(alpha: 0.2)
                    : colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.paperclip,
                    size: 18,
                    color: attachmentsCount > 0
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Attachments',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: attachmentsCount > 0 ? colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Attachment counter (if attachments exist)
          if (attachmentsCount > 0) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.image, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    '$attachmentsCount/10',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Event date button (only for events and if no attachments counter shown)
          if (selectedType == PostType.scheduleEvent &&
              attachmentsCount == 0) ...[
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onSelectDate,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  side: BorderSide(
                    color: scheduledDate != null
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                  ),
                  backgroundColor: scheduledDate != null
                      ? colorScheme.primaryContainer.withValues(alpha: 0.2)
                      : colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 18,
                      color: scheduledDate != null
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      scheduledDate == null
                          ? 'Event Date'
                          : '${scheduledDate!.month}/${scheduledDate!.day}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: scheduledDate != null
                            ? colorScheme.primary
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
