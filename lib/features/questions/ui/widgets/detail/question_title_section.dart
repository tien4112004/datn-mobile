import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';

/// Question Title Section - Displays the question title with enhanced typography
///
/// Features:
/// - Uppercase section label with increased letter spacing
/// - Large, bold title typography (displaySmall w800)
/// - Proper visual hierarchy with Material 3 styling
class QuestionTitleSection extends StatelessWidget {
  final BaseQuestion question;

  const QuestionTitleSection({super.key, required this.question});

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
            ),
          ),
        ],
      ),
    );
  }
}
