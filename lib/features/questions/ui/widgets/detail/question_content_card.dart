import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';

// Import viewing widgets
import 'package:datn_mobile/features/questions/ui/widgets/multiple_choice/multiple_choice_viewing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/matching/matching_viewing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/fill_in_blank/fill_in_blank_viewing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/open_ended/open_ended_viewing.dart';

/// Question Content Card - Material 3 card displaying question content with points badge
///
/// Features:
/// - Material 3 FilledCard styling with subtle elevation
/// - Header with "QUESTION CONTENT" label and points badge
/// - Type-specific content rendering
/// - Consistent padding and rounded corners (16px)
class QuestionContentCard extends StatelessWidget {
  final BaseQuestion question;

  const QuestionContentCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'QUESTION CONTENT',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          // Question Content - Type-specific rendering
          _buildTypeSpecificContent(question),
        ],
      ),
    );
  }

  /// Renders type-specific question content using appropriate viewing widgets
  Widget _buildTypeSpecificContent(BaseQuestion question) {
    if (question is MultipleChoiceQuestion) {
      return MultipleChoiceViewing(question: question);
    } else if (question is MatchingQuestion) {
      return MatchingViewing(question: question);
    } else if (question is FillInBlankQuestion) {
      return FillInBlankViewing(question: question);
    } else if (question is OpenEndedQuestion) {
      return OpenEndedViewing(question: question);
    }

    return const SizedBox.shrink();
  }
}
