import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/shared/widgets/question_badges.dart';

class QuestionTitleSection extends StatelessWidget {
  final BaseQuestion question;
  final String? grade;
  final String? subject;

  const QuestionTitleSection({
    super.key,
    required this.question,
    this.grade,
    this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Label
          Text(
            'QUESTION TITLE',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),

          // Question Title - Large, Bold
          Text(
            question.title,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.1,
              color: colorScheme.onSurface,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 16),

          // Chips Row (Grade, Subject, Type)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Type Badge
              QuestionTypeBadge(
                type: question.type,
                iconSize: 16,
                fontSize: 12,
              ),

              // Difficulty Badge
              DifficultyBadge(
                difficulty: question.difficulty,
                iconSize: 16,
                fontSize: 12,
              ),

              // Grade Badge
              if (grade != null) _buildMetaChip(context, grade!),

              // Subject Badge
              if (subject != null) _buildMetaChip(context, subject!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
    );
  }
}
