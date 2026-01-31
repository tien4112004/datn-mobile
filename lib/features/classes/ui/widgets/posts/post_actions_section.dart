import 'package:AIPrimary/features/classes/domain/entity/post_type.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Actions section for attachments and linked resources
class PostActionsSection extends StatelessWidget {
  final PostType selectedType;
  final int attachmentsCount;
  final int linkedResourcesCount;
  final bool isLoading;
  final bool isUploading;
  final VoidCallback onPickAttachment;
  final VoidCallback onPickLinkedResource;

  const PostActionsSection({
    super.key,
    required this.selectedType,
    required this.attachmentsCount,
    this.linkedResourcesCount = 0,
    required this.isLoading,
    this.isUploading = false,
    required this.onPickAttachment,
    required this.onPickLinkedResource,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isExercise = selectedType == PostType.exercise;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // First Row - Attachments and Link Resource
          Row(
            children: [
              // Attachments button (hidden for Exercise type)
              if (!isExercise)
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

              if (!isExercise) const SizedBox(width: 12),

              // Link Resource button (for Exercise: Assignment only)
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
                        isExercise ? LucideIcons.fileText : LucideIcons.link,
                        size: 18,
                        color: linkedResourcesCount > 0
                            ? colorScheme.secondary
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isExercise
                            ? (linkedResourcesCount > 0
                                  ? 'Assignment ($linkedResourcesCount)'
                                  : 'Attach Assignment')
                            : (linkedResourcesCount > 0
                                  ? 'Linked ($linkedResourcesCount)'
                                  : 'Link Resource'),
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
        ],
      ),
    );
  }
}
