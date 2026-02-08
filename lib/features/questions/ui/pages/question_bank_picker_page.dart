import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/features/assignments/states/controller_provider.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/question_points_assignment_dialog.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_bank_item_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/features/questions/states/question_bank_provider.dart';
import 'package:AIPrimary/features/questions/states/question_bank_filter_state.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/utils/enum_localizations.dart';
import 'package:AIPrimary/shared/widgets/generic_filters_bar.dart';
import 'package:AIPrimary/features/questions/ui/widgets/advanced_question_filter_dialog.dart';
import 'package:AIPrimary/features/questions/ui/widgets/bank_type_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Page for selecting questions from the question bank.
///
/// Provides:
/// - Multi-select functionality
/// - Filter by type and difficulty
/// - Search capability
/// - Points assignment dialog
/// - Returns selected questions as AssignmentQuestionEntity list with assigned points
@RoutePage()
class QuestionBankPickerPage extends ConsumerStatefulWidget {
  const QuestionBankPickerPage({super.key});

  @override
  ConsumerState<QuestionBankPickerPage> createState() =>
      _QuestionBankPickerPageState();
}

class _QuestionBankPickerPageState
    extends ConsumerState<QuestionBankPickerPage> {
  // Store full question objects instead of just IDs
  final Map<String, QuestionBankItemEntity> _selectedQuestions = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial filter to personal bank
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentFilter = ref.read(questionBankFilterProvider);
      if (currentFilter.searchQuery != null) {
        _searchController.text = currentFilter.searchQuery!;
      }

      ref.read(questionBankFilterProvider.notifier).state =
          const QuestionBankFilterState();
      ref.read(questionBankProvider.notifier).loadQuestionsWithFilter();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(QuestionBankItemEntity bankItem) {
    setState(() {
      if (_selectedQuestions.containsKey(bankItem.id)) {
        _selectedQuestions.remove(bankItem.id);
      } else {
        _selectedQuestions[bankItem.id] = bankItem;
      }
    });
  }

  Future<void> _handleContinue() async {
    if (_selectedQuestions.isEmpty) {
      final t = ref.read(translationsPod);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.questionBank.errors.selectAtLeastOne)),
      );
      return;
    }

    final selectedQuestions = _selectedQuestions.values.toList();

    // Fetch context titles for questions that have contextId
    final contextIds = selectedQuestions
        .where((q) => q.contextId != null)
        .map((q) => q.contextId!)
        .toSet()
        .toList();

    List<String> contextTitles = [];
    if (contextIds.isNotEmpty) {
      try {
        final repository = ref.read(contextRepositoryProvider);
        final contexts = await repository.getContextsByIds(contextIds);
        contextTitles = contexts.map((c) => c.title).toList();
      } catch (_) {
        // If fetch fails, show dialog without titles
      }
    }

    if (!mounted) return;

    // Show points assignment dialog
    final assignmentQuestions = await QuestionPointsAssignmentDialog.show(
      context,
      selectedQuestions,
      contextTitles: contextTitles,
    );

    // Only pop if user confirmed (didn't cancel the dialog)
    if (assignmentQuestions != null && mounted) {
      if (!context.mounted) return;
      context.router.maybePop<List<AssignmentQuestionEntity>>(
        assignmentQuestions,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final questionBankState = ref.watch(questionBankProvider);
    final currentFilter = ref.watch(questionBankFilterProvider);
    final t = ref.watch(translationsPod);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // SliverAppBar with title and selected count
              SliverAppBar(
                floating: true,
                pinned: true,
                title: Text(t.questionBank.selectQuestions),
                actions: [
                  // Selected count badge
                  if (_selectedQuestions.isNotEmpty)
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
                          '${_selectedQuestions.length}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Search and filters section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: colorScheme.surface,
                  child: Column(
                    children: [
                      // Bank type switcher
                      BankTypeSwitcher(
                        selectedType: currentFilter.bankType,
                        onTypeChanged: (type) {
                          ref.read(questionBankFilterProvider.notifier).state =
                              currentFilter.copyWith(bankType: type);
                          ref
                              .read(questionBankProvider.notifier)
                              .loadQuestionsWithFilter();
                        },
                      ),
                      const SizedBox(height: 12),
                      // Search bar
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: t.questionBank.search.hint,
                          prefixIcon: Icon(
                            LucideIcons.search,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    LucideIcons.x,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref
                                        .read(
                                          questionBankFilterProvider.notifier,
                                        )
                                        .state = currentFilter.copyWith(
                                      searchQuery: null,
                                    );
                                    ref
                                        .read(questionBankProvider.notifier)
                                        .loadQuestionsWithFilter();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                        ),
                        onChanged: (value) {
                          setState(() {}); // Rebuild to show/hide clear button
                        },
                        onSubmitted: (value) {
                          final query = value.trim().isEmpty
                              ? null
                              : value.trim();
                          ref.read(questionBankFilterProvider.notifier).state =
                              currentFilter.copyWith(searchQuery: query);
                          ref
                              .read(questionBankProvider.notifier)
                              .loadQuestionsWithFilter();
                        },
                        textInputAction: TextInputAction.search,
                      ),
                      const SizedBox(height: 12),

                      // Filter chips bar matching Question Bank page
                      GenericFiltersBar(
                        filters: [
                          FilterConfig<GradeLevel>(
                            label: t.questionBank.filters.grade,
                            icon: LucideIcons.graduationCap,
                            options: GradeLevel.values,
                            allLabel: t.questionBank.filters.allGrades,
                            allIcon: LucideIcons.list,
                            selectedValue: currentFilter.gradeFilter,
                            onChanged: (value) {
                              ref
                                  .read(questionBankFilterProvider.notifier)
                                  .state = currentFilter.copyWith(
                                gradeFilter: value,
                              );
                              ref
                                  .read(questionBankProvider.notifier)
                                  .loadQuestionsWithFilter();
                            },
                            displayNameBuilder: (value) =>
                                value.localizedName(t),
                          ),
                          FilterConfig<Subject>(
                            label: t.questionBank.filters.subject,
                            icon: LucideIcons.bookOpen,
                            options: Subject.values,
                            allLabel: t.questionBank.filters.allSubjects,
                            allIcon: LucideIcons.list,
                            selectedValue: currentFilter.subjectFilter,
                            onChanged: (value) {
                              ref
                                  .read(questionBankFilterProvider.notifier)
                                  .state = currentFilter.copyWith(
                                subjectFilter: value,
                              );
                              ref
                                  .read(questionBankProvider.notifier)
                                  .loadQuestionsWithFilter();
                            },
                            displayNameBuilder: (value) =>
                                value.localizedName(t),
                          ),
                          FilterConfig<QuestionType>(
                            label: t.questionBank.filters.type,
                            icon: LucideIcons.circleQuestionMark,
                            options: QuestionType.values,
                            allLabel: t.questionBank.filters.allTypes,
                            allIcon: LucideIcons.list,
                            selectedValue: currentFilter.questionTypeFilter,
                            onChanged: (value) {
                              ref
                                  .read(questionBankFilterProvider.notifier)
                                  .state = currentFilter.copyWith(
                                questionTypeFilter: value,
                              );
                              ref
                                  .read(questionBankProvider.notifier)
                                  .loadQuestionsWithFilter();
                            },
                            displayNameBuilder: (value) =>
                                value.localizedName(t),
                          ),
                          FilterConfig<Difficulty>(
                            label: t.questionBank.filters.difficulty,
                            icon: LucideIcons.gauge,
                            options: Difficulty.values,
                            allLabel: t.questionBank.filters.allDifficulties,
                            allIcon: LucideIcons.list,
                            selectedValue: currentFilter.difficultyFilter,
                            onChanged: (value) {
                              ref
                                  .read(questionBankFilterProvider.notifier)
                                  .state = currentFilter.copyWith(
                                difficultyFilter: value,
                              );
                              ref
                                  .read(questionBankProvider.notifier)
                                  .loadQuestionsWithFilter();
                            },
                            displayNameBuilder: (value) =>
                                value.localizedName(t),
                          ),
                        ],
                        onClearFilters: () {
                          HapticFeedback.lightImpact();
                          ref.read(questionBankFilterProvider.notifier).state =
                              currentFilter.clearFilters();
                          ref
                              .read(questionBankProvider.notifier)
                              .loadQuestionsWithFilter();
                        },
                        useWrap: true,
                        trailing: [
                          InkWell(
                            onTap: () => showAdvancedQuestionFilterDialog(
                              context: context,
                              ref: ref,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: colorScheme.secondary,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                LucideIcons.slidersHorizontal,
                                size: 16,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Questions list
              questionBankState.when(
                data: (state) {
                  final questions = state.questions;
                  if (questions.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
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
                              t.questionBank.search.noResults,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      _selectedQuestions.isNotEmpty ? 96 : 8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final bankItem = questions[index];
                        final isSelected = _selectedQuestions.containsKey(
                          bankItem.id,
                        );

                        return _QuestionSelectionCard(
                          bankItem: bankItem,
                          isSelected: isSelected,
                          onToggle: () => _toggleSelection(bankItem),
                        );
                      }, childCount: questions.length),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SliverFillRemaining(
                  child: Center(child: Text('Error: $error')),
                ),
              ),
            ],
          ),

          // Bottom action bar
          if (_selectedQuestions.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
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
                          t.questionBank.picker.questionsSelected(
                            count: _selectedQuestions.length.toString(),
                          ),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      FilledButton(
                        onPressed: _handleContinue,
                        child: Text(t.questionBank.continue_),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Card widget for selectable question
class _QuestionSelectionCard extends ConsumerWidget {
  final QuestionBankItemEntity bankItem;
  final bool isSelected;
  final VoidCallback onToggle;

  const _QuestionSelectionCard({
    required this.bankItem,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final question = bankItem.question;
    final t = ref.watch(translationsPod);

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
                            label: question.type.localizedName(t),
                            color: QuestionType.getColor(question.type),
                          ),
                          _InfoChip(
                            icon: Difficulty.getDifficultyIcon(
                              question.difficulty,
                            ),
                            label: question.difficulty.localizedName(t),
                            color: Difficulty.getDifficultyColor(
                              question.difficulty,
                            ),
                          ),
                          if (bankItem.grade != null)
                            _InfoChip(
                              icon: LucideIcons.graduationCap,
                              label: bankItem.grade!.localizedName(t),
                              color: colorScheme.tertiary,
                            ),
                          if (bankItem.contextId != null)
                            _InfoChip(
                              icon: LucideIcons.bookOpen,
                              label: t.assignments.context.readingPassage,
                              color: colorScheme.secondary,
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
