import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_bank_item_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/utils/enum_localizations.dart';

/// Card component for displaying question items in a list
///
/// Extracted from `question_bank_page.dart` to improve maintainability
/// and enable reuse across the app (question selection, exam builder, etc.)
class QuestionListCard extends ConsumerWidget {
  final QuestionBankItemEntity item;
  final VoidCallback? onTap;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isCompact;

  const QuestionListCard({
    super.key,
    required this.item,
    this.onTap,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final question = item.question;
    final t = ref.watch(translationsPod);

    return Card(
      key: ValueKey(item.id),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ?? onView,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              // More menu positioned at top-right
              if (showActions)
                Positioned(
                  top: -8,
                  right: -8,
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          onView?.call();
                          break;
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 18,
                              color: colorScheme.onSurface,
                            ),
                            const SizedBox(width: 12),
                            Text(t.questionBank.actions.view),
                          ],
                        ),
                      ),
                      if (onEdit != null)
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: colorScheme.onSurface,
                              ),
                              const SizedBox(width: 12),
                              Text(t.questionBank.actions.edit),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                t.questionBank.actions.delete,
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question title with padding for menu
                  Padding(
                    padding: EdgeInsets.only(right: showActions ? 32 : 0),
                    child: Text(
                      question.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Description (if available in future)
                  if (!isCompact &&
                      question.explanation != null &&
                      question.explanation!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      question.explanation!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Footer: all metadata consolidated (full width)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                          width: 1,
                        ),
                      ),
                    ),
                    child: _buildMetadataFooter(context, theme, colorScheme, t),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the consolidated metadata footer with dot separators
  Widget _buildMetadataFooter(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic t,
  ) {
    final question = item.question;
    final difficultyColor = Difficulty.getDifficultyColor(question.difficulty);
    final difficultyIcon = Difficulty.getDifficultyIcon(question.difficulty);
    final typeIcon = QuestionType.getIcon(question.type);
    final typeColor = QuestionType.getColor(question.type);

    final metadataItems = <Widget>[];

    // Question Type
    metadataItems.add(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(typeIcon, size: 14, color: typeColor),
          const SizedBox(width: 4),
          Text(
            question.type.localizedName(t),
            style: theme.textTheme.bodySmall?.copyWith(
              color: typeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    // Grade
    if (item.grade != null) {
      metadataItems.add(
        Text(
          item.grade!.localizedName(t),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // Subject
    if (item.subject != null) {
      metadataItems.add(
        Text(
          item.subject!.localizedName(t),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // Difficulty (with color)
    metadataItems.add(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(difficultyIcon, size: 14, color: difficultyColor),
          const SizedBox(width: 4),
          Text(
            question.difficulty.localizedName(t),
            style: theme.textTheme.bodySmall?.copyWith(
              color: difficultyColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    // Chapter
    if (item.chapter != null && item.chapter!.isNotEmpty) {
      metadataItems.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                item.chapter!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // Build row with dot separators
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < metadataItems.length; i++) ...[
          metadataItems[i],
          if (i < metadataItems.length - 1)
            Text(
              '•',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
        ],
      ],
    );
  }
}
