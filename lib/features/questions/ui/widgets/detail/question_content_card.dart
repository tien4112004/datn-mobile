import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/multiple_choice/multiple_choice_viewing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/matching/matching_viewing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/fill_in_blank/fill_in_blank_viewing.dart';
import 'package:AIPrimary/features/questions/ui/widgets/open_ended/open_ended_viewing.dart';

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildTypeSpecificContent(question),
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
