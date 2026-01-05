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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Attachments button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onPickAttachment,
              icon: const Icon(LucideIcons.paperclip, size: 18),
              label: Text(
                attachmentsCount == 0
                    ? 'Attachments'
                    : '$attachmentsCount file${attachmentsCount > 1 ? 's' : ''}',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                side: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
                backgroundColor: attachmentsCount > 0
                    ? colorScheme.tertiaryContainer
                    : null,
                foregroundColor: attachmentsCount > 0
                    ? colorScheme.onTertiaryContainer
                    : null,
              ),
            ),
          ),

          // Event date button (only for events)
          if (selectedType == PostType.scheduleEvent) ...[
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onSelectDate,
                icon: const Icon(LucideIcons.calendarClock, size: 18),
                label: Text(
                  scheduledDate == null
                      ? 'Event Date'
                      : '${scheduledDate!.month}/${scheduledDate!.day}',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  side: BorderSide(
                    color: scheduledDate != null
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  backgroundColor: scheduledDate != null
                      ? colorScheme.primaryContainer
                      : null,
                  foregroundColor: scheduledDate != null
                      ? colorScheme.onPrimaryContainer
                      : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
