import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/features/assignments/domain/entity/context_entity.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/context/context_group_card.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/question_card.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/widgets/enhanced_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Questions tab with clean design matching the Questions tab reference.
/// Features: Icon badge header, clean question list, numbered cards.
/// Supports grouping questions by context (reading passage).
class QuestionsTab extends ConsumerWidget {
  final AssignmentEntity assignment;
  final bool isEditMode;
  final Function(AssignmentQuestionEntity, int) onEdit;
  final Function(int) onDelete;
  final void Function() onSwitchMode;

  /// Map of context IDs to context entities for grouping display
  final Map<String, ContextEntity> contextsMap;

  /// Callback when context edit is requested
  final void Function(ContextEntity context)? onEditContext;

  const QuestionsTab({
    super.key,
    required this.assignment,
    this.isEditMode = false,
    required this.onEdit,
    required this.onDelete,
    required this.onSwitchMode,
    this.contextsMap = const {},
    this.onEditContext,
  });

  /// Groups ALL questions by contextId (not just consecutive ones).
  /// Returns a list of grouped items preserving order of first appearance.
  ///
  /// Algorithm:
  /// 1. Iterate through questions, tracking which contextIds we've seen.
  /// 2. For a question with a known contextId:
  ///    - If first time seeing this contextId, create a new group and record
  ///      all question indices (scanning full list) for this contextId.
  ///    - If already seen, skip (already included in the earlier group).
  /// 3. For standalone questions (no contextId or unknown), add individually.
  List<_QuestionGroupItem> _groupQuestionsByContext() {
    final groups = <_QuestionGroupItem>[];
    final questions = assignment.questions;
    final processedContextIds = <String>{};

    // Running display number (1-based)
    // We need to pre-compute display numbers since groups collect
    // non-consecutive questions. Simplest: display number = original index + 1.
    // But grouped display should be sequential within the output order.
    // Let's build the ordered list first, then assign display numbers.

    // First pass: build ordered groups
    final orderedItems = <_QuestionGroupItem>[];

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final contextId = question.contextId;

      if (contextId != null && contextsMap.containsKey(contextId)) {
        // Context question
        if (processedContextIds.contains(contextId)) {
          // Already grouped — skip
          continue;
        }
        processedContextIds.add(contextId);

        // Collect ALL questions with this contextId and their original indices
        final contextQuestions = <AssignmentQuestionEntity>[];
        final originalIndices = <int>[];
        for (int j = 0; j < questions.length; j++) {
          if (questions[j].contextId == contextId) {
            contextQuestions.add(questions[j]);
            originalIndices.add(j);
          }
        }

        orderedItems.add(
          _QuestionGroupItem.group(
            context: contextsMap[contextId]!,
            questions: contextQuestions,
            originalIndices: originalIndices,
          ),
        );
      } else {
        // Standalone question
        orderedItems.add(
          _QuestionGroupItem.standalone(question: question, originalIndex: i),
        );
      }
    }

    // Second pass: assign sequential display numbers
    int displayNumber = 1;
    for (final item in orderedItems) {
      if (item.isStandalone) {
        item.displayNumber = displayNumber;
        displayNumber++;
      } else {
        item.groupDisplayStart = displayNumber;
        displayNumber += item.groupQuestions!.length;
      }
      groups.add(item);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final groupedItems = _groupQuestionsByContext();
    final t = ref.watch(translationsPod);

    return Container(
      color: colorScheme.surfaceContainerLowest,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Text(
                    t.assignments.detail.questions.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${assignment.totalQuestions})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final groupItem = groupedItems[index];

                  if (groupItem.isStandalone) {
                    // Standalone question
                    return QuestionCard(
                      key: ValueKey(groupItem.standaloneQuestion!.question.id),
                      question: groupItem.standaloneQuestion!.question,
                      questionNumber: groupItem.displayNumber!,
                      isEditMode: isEditMode,
                      onEdit: () => onEdit(
                        groupItem.standaloneQuestion!,
                        groupItem.standaloneIndex!,
                      ),
                      onDelete: () => onDelete(groupItem.standaloneIndex!),
                    );
                  } else {
                    // Context group
                    return ContextGroupCard(
                      key: ValueKey('context_${groupItem.context!.id}'),
                      context: groupItem.context!,
                      questions: groupItem.groupQuestions!,
                      startIndex: groupItem.groupOriginalIndices!.first,
                      startingDisplayNumber: groupItem.groupDisplayStart!,
                      isEditMode: isEditMode,
                      onEditContext: onEditContext != null
                          ? () => onEditContext!(groupItem.context!)
                          : null,
                      onEditQuestion: (question, idx) => onEdit(question, idx),
                      onDeleteQuestion: (idx) => onDelete(idx),
                      questionCountLabel: t.assignments.context.questionCount(
                        count: groupItem.groupQuestions!.length,
                      ),
                      readingPassageLabel: t.assignments.context.readingPassage,
                    );
                  }
                }, childCount: groupedItems.length),
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

/// Helper class to represent grouped question items
class _QuestionGroupItem {
  final bool isStandalone;

  // For standalone questions
  final AssignmentQuestionEntity? standaloneQuestion;
  final int? standaloneIndex;

  // For context groups
  final ContextEntity? context;
  final List<AssignmentQuestionEntity>? groupQuestions;
  final List<int>? groupOriginalIndices;

  // Display numbers (assigned in second pass)
  int? displayNumber; // For standalone
  int? groupDisplayStart; // For groups (1-based starting display number)

  _QuestionGroupItem._({
    required this.isStandalone,
    this.standaloneQuestion,
    this.standaloneIndex,
    this.context,
    this.groupQuestions,
    this.groupOriginalIndices,
  });

  factory _QuestionGroupItem.standalone({
    required AssignmentQuestionEntity question,
    required int originalIndex,
  }) {
    return _QuestionGroupItem._(
      isStandalone: true,
      standaloneQuestion: question,
      standaloneIndex: originalIndex,
    );
  }

  factory _QuestionGroupItem.group({
    required ContextEntity context,
    required List<AssignmentQuestionEntity> questions,
    required List<int> originalIndices,
  }) {
    return _QuestionGroupItem._(
      isStandalone: false,
      context: context,
      groupQuestions: questions,
      groupOriginalIndices: originalIndices,
    );
  }
}
