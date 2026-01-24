import 'package:datn_mobile/features/classes/domain/entity/post_type.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Actions section for attachments and event date selection
class PostActionsSection extends StatelessWidget {
  final PostType selectedType;
  final int attachmentsCount;
  final int linkedResourcesCount;
  final DateTime? scheduledDate;
  final bool isLoading;
  final bool isUploading;
  final VoidCallback onPickAttachment;
  final VoidCallback onPickLinkedResource;
  final VoidCallback onSelectDate;

  const PostActionsSection({
    super.key,
    required this.selectedType,
    required this.attachmentsCount,
    this.linkedResourcesCount = 0,
    required this.scheduledDate,
    required this.isLoading,
    this.isUploading = false,
    required this.onPickAttachment,
    required this.onPickLinkedResource,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // First Row - Attachments and Link Resource
          Row(
            children: [
              // Attachments button
              Expanded(
                child: OutlinedButton(
                  onPressed: (isLoading || isUploading)
                      ? null
                      : onPickAttachment,
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
                      if (isUploading)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      else
                        Icon(
                          LucideIcons.paperclip,
                          size: 18,
                          color: attachmentsCount > 0
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        isUploading
                            ? 'Uploading...'
                            : (attachmentsCount > 0
                                  ? 'Add More ($attachmentsCount)'
                                  : 'Add Attachments'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: attachmentsCount > 0
                              ? colorScheme.primary
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Link Resource button
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : onPickLinkedResource,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    side: BorderSide(
                      color: linkedResourcesCount > 0
                          ? colorScheme.secondary.withValues(alpha: 0.3)
                          : colorScheme.outlineVariant,
                    ),
                    backgroundColor: linkedResourcesCount > 0
                        ? colorScheme.secondaryContainer.withValues(alpha: 0.2)
                        : colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.link,
                        size: 18,
                        color: linkedResourcesCount > 0
                            ? colorScheme.secondary
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        linkedResourcesCount > 0
                            ? 'Linked ($linkedResourcesCount)'
                            : 'Link Resource',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: linkedResourcesCount > 0
                              ? colorScheme.secondary
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Event date button (only for events)
          if (selectedType == PostType.scheduleEvent) ...[
            const SizedBox(height: 12),
            OutlinedButton(
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
                        ? 'Select Event Date'
                        : '${scheduledDate!.month}/${scheduledDate!.day}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: scheduledDate != null ? colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
