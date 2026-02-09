import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Grid navigator for jumping between questions
class QuestionNavigator extends ConsumerWidget {
  final int currentIndex;
  final int totalQuestions;
  final List<String> answeredQuestions;
  final Function(int) onQuestionSelected;

  const QuestionNavigator({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.onQuestionSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(LucideIcons.grid3x3, size: 24, color: colorScheme.onSurface),
              const SizedBox(width: 12),
              Text(
                t.submissions.doing.questionNavigator,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress text
          Text(
            t.submissions.doing.progress(
              answered: answeredQuestions.length,
              total: totalQuestions,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          // Grid of questions
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: totalQuestions,
            itemBuilder: (context, index) {
              final isCurrentQuestion = index == currentIndex;
              // Note: We can't easily check if answered without questionId
              // This is a simplified version

              return InkWell(
                onTap: () => onQuestionSelected(index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isCurrentQuestion
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrentQuestion
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isCurrentQuestion
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Legend
          Row(
            children: [
              _LegendItem(color: colorScheme.primary, label: 'Current'),
              const SizedBox(width: 16),
              _LegendItem(
                color: colorScheme.surfaceContainerHighest,
                label: 'Not visited',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
