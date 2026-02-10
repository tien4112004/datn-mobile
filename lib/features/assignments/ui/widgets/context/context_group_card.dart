import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/context/context_display_card.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/question_card.dart';
import 'package:flutter/material.dart';

/// A card that groups multiple questions under a shared context.
///
/// Features:
/// - Context header with collapsible content
/// - Nested question cards below
/// - Visual grouping indicator
/// - Edit/unlink actions for context
class ContextGroupCard extends StatelessWidget {
  /// The context entity to display
  final ContextEntity context;

  /// Questions that belong to this context
  final List<AssignmentQuestionEntity> questions;

  /// The 0-based starting index of this group in the flat questions list.
  /// Used for correct callback indices.
  final int startIndex;

  /// The 1-based starting question number for display.
  final int startingDisplayNumber;

  /// Whether edit mode is enabled
  final bool isEditMode;

  /// Callback when context edit is requested
  final VoidCallback? onEditContext;

  /// Callback when context unlink is requested
  final VoidCallback? onUnlinkContext;

  /// Callback when a question edit is requested (passes original flat-list index)
  final void Function(AssignmentQuestionEntity question, int index)?
  onEditQuestion;

  /// Callback when a question delete is requested (passes original flat-list index)
  final void Function(int index)? onDeleteQuestion;

  /// Localized label for "Question(s)" count
  final String? questionCountLabel;

  /// Localized label for "Reading Passage" fallback title
  final String? readingPassageLabel;

  /// Map of subtopic IDs to display names
  final Map<String, String> subtopicNameMap;

  const ContextGroupCard({
    super.key,
    required this.context,
    required this.questions,
    required this.startIndex,
    required this.startingDisplayNumber,
    this.isEditMode = false,
    this.onEditContext,
    this.onUnlinkContext,
    this.onEditQuestion,
    this.onDeleteQuestion,
    this.questionCountLabel,
    this.readingPassageLabel,
    this.subtopicNameMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade200.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Context display
          ContextDisplayCard(
            context: this.context,
            initiallyExpanded: false,
            isEditMode: isEditMode,
            onEdit: onEditContext,
            readingPassageLabel: readingPassageLabel,
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              height: 1,
            ),
          ),

          // Questions header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(Icons.quiz_outlined, size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  questionCountLabel ??
                      '${questions.length} ${questions.length == 1 ? 'Question' : 'Questions'}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Nested question cards
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Column(
              children: [
                for (int i = 0; i < questions.length; i++)
                  QuestionCard(
                    key: ValueKey(questions[i].question.id),
                    question: questions[i].question,
                    questionNumber: startingDisplayNumber + i,
                    isEditMode: isEditMode,
                    subtopicName: questions[i].topicId != null
                        ? subtopicNameMap[questions[i].topicId!]
                        : null,
                    onEdit: onEditQuestion != null
                        ? () => onEditQuestion!(questions[i], startIndex + i)
                        : null,
                    onDelete: onDeleteQuestion != null
                        ? () => onDeleteQuestion!(startIndex + i)
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
