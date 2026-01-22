import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_bank_item_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:datn_mobile/features/questions/states/question_bank_provider.dart';
import 'package:datn_mobile/features/questions/states/question_bank_filter_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Page for selecting questions from the question bank.
///
/// Provides:
/// - Multi-select functionality
/// - Filter by type and difficulty
/// - Search capability
/// - Returns selected questions as QuestionBankItemEntity list
@RoutePage()
class QuestionBankPickerPage extends ConsumerStatefulWidget {
  const QuestionBankPickerPage({super.key});

  @override
  ConsumerState<QuestionBankPickerPage> createState() =>
      _QuestionBankPickerPageState();
}

class _QuestionBankPickerPageState
    extends ConsumerState<QuestionBankPickerPage> {
  final Set<String> _selectedQuestionIds = {};

  @override
  void initState() {
    super.initState();
    // Set initial filter to personal bank
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questionBankFilterProvider.notifier).state =
          const QuestionBankFilterState(bankType: BankType.personal);
      ref.read(questionBankProvider.notifier).loadQuestionsWithFilter();
    });
  }

  void _updateFilters({
    String? searchQuery,
    QuestionType? questionType,
    Difficulty? difficulty,
  }) {
    final currentFilter = ref.read(questionBankFilterProvider);
    ref.read(questionBankFilterProvider.notifier).state = currentFilter
        .copyWith(
          searchQuery: searchQuery,
          questionTypeFilter: questionType,
          difficultyFilter: difficulty,
        );
    ref.read(questionBankProvider.notifier).loadQuestionsWithFilter();
  }

  void _toggleSelection(String questionId) {
    setState(() {
      if (_selectedQuestionIds.contains(questionId)) {
        _selectedQuestionIds.remove(questionId);
      } else {
        _selectedQuestionIds.add(questionId);
      }
    });
  }

  void _handleContinue(List<QuestionBankItemEntity> allQuestions) {
    if (_selectedQuestionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one question')),
      );
      return;
    }

    final selectedQuestions = allQuestions
        .where((q) => _selectedQuestionIds.contains(q.id))
        .toList();

    // Simply return the selected questions
    context.router.maybePop<List<QuestionBankItemEntity>>(selectedQuestions);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final questionBankState = ref.watch(questionBankProvider);
    final currentFilter = ref.watch(questionBankFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Questions'),
        actions: [
          // Selected count badge
          if (_selectedQuestionIds.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_selectedQuestionIds.length}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.surface,
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search questions...',
                    prefixIcon: const Icon(LucideIcons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    _updateFilters(searchQuery: value.isEmpty ? null : value);
                  },
                ),
                const SizedBox(height: 12),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Type filters
                      ...QuestionType.values.map((type) {
                        final isSelected =
                            currentFilter.questionTypeFilter == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(type.displayName),
                            selected: isSelected,
                            onSelected: (selected) {
                              _updateFilters(
                                questionType: selected ? type : null,
                              );
                            },
                          ),
                        );
                      }),

                      const SizedBox(width: 8),

                      // Difficulty filters
                      ...[
                        Difficulty.knowledge,
                        Difficulty.comprehension,
                        Difficulty.application,
                      ].map((difficulty) {
                        final isSelected =
                            currentFilter.difficultyFilter == difficulty;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(difficulty.displayName),
                            selected: isSelected,
                            onSelected: (selected) {
                              _updateFilters(
                                difficulty: selected ? difficulty : null,
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Questions list
          Expanded(
            child: questionBankState.when(
              data: (state) {
                final questions = state.questions;
                if (questions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.inbox,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No questions found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final bankItem = questions[index];
                    final isSelected = _selectedQuestionIds.contains(
                      bankItem.id,
                    );

                    return _QuestionSelectionCard(
                      bankItem: bankItem,
                      isSelected: isSelected,
                      onToggle: () => _toggleSelection(bankItem.id),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),

          // Bottom action bar
          if (_selectedQuestionIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    offset: const Offset(0, -4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_selectedQuestionIds.length} question(s) selected',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: () => _handleContinue(
                        questionBankState.value?.questions ?? [],
                      ),
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Card widget for selectable question
class _QuestionSelectionCard extends StatelessWidget {
  final QuestionBankItemEntity bankItem;
  final bool isSelected;
  final VoidCallback onToggle;

  const _QuestionSelectionCard({
    required this.bankItem,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final question = bankItem.question;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox
                Checkbox(value: isSelected, onChanged: (_) => onToggle()),
                const SizedBox(width: 12),

                // Question info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _InfoChip(
                            icon: QuestionType.getIcon(question.type),
                            label: question.type.displayName,
                            color: QuestionType.getColor(question.type),
                          ),
                          _InfoChip(
                            icon: Difficulty.getDifficultyIcon(
                              question.difficulty,
                            ),
                            label: question.difficulty.displayName,
                            color: Difficulty.getDifficultyColor(
                              question.difficulty,
                            ),
                          ),
                          if (bankItem.grade != null)
                            _InfoChip(
                              icon: LucideIcons.graduationCap,
                              label: bankItem.grade!.displayName,
                              color: colorScheme.tertiary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small info chip widget
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
