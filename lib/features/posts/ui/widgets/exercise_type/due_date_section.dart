import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Due date selection section for exercise posts
class DueDateSection extends StatelessWidget {
  final DateTime? dueDate;
  final bool isDisabled;
  final VoidCallback onPickDueDate;
  final Translations translations;

  const DueDateSection({
    super.key,
    required this.dueDate,
    required this.isDisabled,
    required this.onPickDueDate,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isDisabled ? null : onPickDueDate,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Calendar Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.calendar,
                    size: 20,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),

                // Date Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translations.classes.postUpsert.dueDate,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dueDate != null
                            ? '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'
                            : translations.classes.postUpsert.dueDateHint,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: dueDate != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                          fontWeight: dueDate != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
