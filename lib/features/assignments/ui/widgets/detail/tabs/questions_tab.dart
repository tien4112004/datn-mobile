import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/question_card.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/widgets/enhanced_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Questions tab with clean design matching the Questions tab reference.
/// Features: Icon badge header, clean question list, numbered cards.
class QuestionsTab extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

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
                          t.assignments.detail.questions.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.assignments.detail.questions.available(
                            count: assignment.totalQuestions,
                          ),
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
                          title: t.assignments.detail.questions.emptyTitle,
                          message: t.assignments.detail.questions.emptyMessage,
                          actionLabel:
                              t.assignments.detail.questions.addQuestion,
                          onAction: () => onSwitchMode(),
                        )
                      : EnhancedEmptyState(
                          icon: LucideIcons.plus,
                          title: t.assignments.detail.questions.emptyEditTitle,
                          message:
                              t.assignments.detail.questions.emptyEditMessage,
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
