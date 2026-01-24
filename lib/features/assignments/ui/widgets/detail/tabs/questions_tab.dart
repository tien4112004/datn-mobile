import 'package:datn_mobile/features/assignments/domain/entity/assignment_entity.dart';
import 'package:datn_mobile/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:datn_mobile/features/assignments/ui/widgets/detail/question_card.dart';
import 'package:datn_mobile/shared/widget/enhanced_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Questions tab with clean design matching the Questions tab reference.
/// Features: Icon badge header, clean question list, numbered cards.
class QuestionsTab extends StatelessWidget {
  final AssignmentEntity assignment;
  final bool isEditMode;
  final Function(AssignmentQuestionEntity, int) onEdit;
  final Function(int) onDelete;
  final void Function() onSwitchMode;

  const QuestionsTab({
    super.key,
    required this.assignment,
    this.isEditMode = false,
    required this.onEdit,
    required this.onDelete,
    required this.onSwitchMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surfaceContainerLowest,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Questions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${assignment.totalQuestions} ${assignment.totalQuestions == 1 ? 'question' : 'questions'} available',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Questions List or Empty State
          if (assignment.questions.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: !isEditMode
                      ? EnhancedEmptyState(
                          icon: LucideIcons.inbox,
                          title: 'No questions yet',
                          message:
                              'You can add questions to this assignment by tapping the "Add Question" button.',
                          actionLabel: 'Add Question',
                          onAction: () => onSwitchMode(),
                        )
                      : const EnhancedEmptyState(
                          icon: LucideIcons.plus,
                          title: 'Add your first Question',
                          message:
                              'Use the Floating Action Button to add your first question.',
                        ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final questionEntity = assignment.questions[index];
                  return QuestionCard(
                    key: ValueKey(questionEntity.question.id),
                    question: questionEntity.question,
                    questionNumber: index + 1,
                    isEditMode: isEditMode,
                    onEdit: () => onEdit(questionEntity, index),
                    onDelete: () => onDelete(index),
                  );
                }, childCount: assignment.questions.length),
              ),
            ),

          // Bottom padding to avoid content being hidden by tab bar/FAB/dock
          SliverToBoxAdapter(
            child: SizedBox(height: isEditMode ? 190.0 : 88.0),
          ),
        ],
      ),
    );
  }
}
