import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Section header for questions list with generation action.
/// Follows Material Design 3 with consistent styling.
class QuestionsSection extends ConsumerWidget {
  final int questionCount;
  final VoidCallback? onGenerate;

  const QuestionsSection({
    super.key,
    required this.questionCount,
    this.onGenerate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          // Section icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LucideIcons.listOrdered,
              color: colorScheme.onSecondaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Section title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.assignments.questionsSection.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  t.assignments.questionsSection.count(count: questionCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Generate button
          if (onGenerate != null)
            FilledButton.tonalIcon(
              onPressed: onGenerate,
              icon: const Icon(LucideIcons.sparkles, size: 18),
              label: Text(t.assignments.questionsSection.generate),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }
}
