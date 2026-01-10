import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/features/questions/provider/question_bank_provider.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_bank_item_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:datn_mobile/features/questions/ui/widgets/question_list_card.dart';
import 'package:datn_mobile/features/questions/ui/widgets/bank_type_switcher.dart';
import 'package:datn_mobile/shared/widget/enhanced_empty_state.dart';

/// Question Bank management page for teachers.
/// Displays personal and public question banks with search and CRUD operations.
@RoutePage()
class QuestionBankPage extends ConsumerStatefulWidget {
  const QuestionBankPage({super.key});

  @override
  ConsumerState<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends ConsumerState<QuestionBankPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questionBankProvider.notifier).loadQuestions();
    });

    // Setup infinite scroll
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // ref.read(questionBankProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionBankProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      appBar: CustomAppBar(
        title: 'Question Bank',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              ref.read(questionBankProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab switcher and search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Column(
              children: [
                // Bank type switcher
                BankTypeSwitcher(
                  selectedType: state.currentBankType,
                  onTypeChanged: (type) {
                    ref
                        .read(questionBankProvider.notifier)
                        .switchBankType(type);
                  },
                ),
                const SizedBox(height: 16),
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search questions...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(questionBankProvider.notifier)
                                  .clearSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
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
                  onSubmitted: (value) {
                    ref.read(questionBankProvider.notifier).search(value);
                  },
                  onChanged: (value) {
                    setState(() {}); // Update to show/hide clear button
                  },
                ),
              ],
            ),
          ),

          // Question list or loading/empty state
          Expanded(
            child: state.isLoading && state.questions.isEmpty
                ? _buildLoadingState()
                : state.questions.isEmpty
                ? _buildEmptyState(theme, state.currentBankType)
                : _buildQuestionList(state),
          ),
        ],
      ),
      floatingActionButton: state.currentBankType == BankType.personal
          ? FloatingActionButton.extended(
              onPressed: () {
                context.router.navigate(QuestionModifyRoute(questionId: null));
              },
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Question'),
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 100,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 20,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 20,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, BankType bankType) {
    final isPersonal = bankType == BankType.personal;

    return EnhancedEmptyState(
      icon: isPersonal ? Icons.quiz_outlined : Icons.public_outlined,
      title: isPersonal ? 'No questions yet' : 'No public questions found',
      message: isPersonal
          ? 'Create your first question to build your question bank'
          : 'Try adjusting your search or check back later',
      actionLabel: isPersonal ? 'Create Question' : null,
      onAction: isPersonal
          ? () {
              // TODO: Navigate to question creation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Question creation coming soon!')),
              );
            }
          : null,
    );
  }

  Widget _buildQuestionList(QuestionBankState state) {
    final isPersonal = state.currentBankType == BankType.personal;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(questionBankProvider.notifier).refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.questions.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.questions.length) {
            return _buildLoadingMoreIndicator();
          }

          final item = state.questions[index];
          return QuestionListCard(
            item: item,
            onView: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('View: ${item.id}')));
            },
            onEdit: isPersonal
                ? () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Edit: ${item.id}')));
                  }
                : null,
            onDelete: isPersonal ? () => _showDeleteConfirmation(item) : null,
            showActions: true,
          );
        },
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  void _showDeleteConfirmation(QuestionBankItemEntity item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.error,
            size: 48,
          ),
          title: const Text('Delete Question'),
          content: Text(
            'Are you sure you want to delete "${item.question.title}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref.read(questionBankProvider.notifier).deleteQuestion(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Question deleted successfully'),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
