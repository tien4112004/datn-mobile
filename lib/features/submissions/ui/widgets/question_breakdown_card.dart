import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Widget showing breakdown of questions by type
class QuestionBreakdownCard extends ConsumerWidget {
  final AssignmentEntity assignment;

  const QuestionBreakdownCard({super.key, required this.assignment});

  Map<QuestionType, int> _getQuestionCounts() {
    final counts = <QuestionType, int>{};

    for (final question in assignment.questions) {
      final type = question.question.type;
      counts[type] = (counts[type] ?? 0) + 1;
    }

    return counts;
  }

  IconData _getIconForType(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return LucideIcons.circleCheck;
      case QuestionType.fillInBlank:
        return LucideIcons.penLine;
      case QuestionType.matching:
        return LucideIcons.equal;
      case QuestionType.openEnded:
        return LucideIcons.pen;
    }
  }

  String _getLabelForType(QuestionType type, Translations t) {
    switch (type) {
      case QuestionType.multipleChoice:
        return t.questions.types.multipleChoice;
      case QuestionType.fillInBlank:
        return t.questions.types.fillInBlank;
      case QuestionType.matching:
        return t.questions.types.matching;
      case QuestionType.openEnded:
        return t.questions.types.openEnded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final questionCounts = _getQuestionCounts();

    if (questionCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.assignments.detail.questionsBreakdown,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: questionCounts.entries.map((entry) {
              final type = entry.key;
              final count = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      _getIconForType(type),
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getLabelForType(type, t),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        count.toString(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
