import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/questions/ui/widgets/question_bank_loading.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/features/questions/states/question_bank_provider.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_bank_item_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:datn_mobile/features/questions/ui/widgets/question_bank_header.dart';
import 'package:datn_mobile/features/questions/ui/widgets/question_bank_list.dart';
import 'package:datn_mobile/shared/widget/enhanced_empty_state.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questionBankProvider.notifier).loadQuestions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionBankController = ref.watch(questionBankProvider);
    final questionBankControllerNotifier = ref.watch(
      questionBankProvider.notifier,
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            floating: false,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: colorScheme.surface,
            leading: Semantics(
              label: 'Go back',
              button: true,
              hint: 'Double tap to return to previous page',
              child: IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.router.maybePop();
                },
                tooltip: 'Back',
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
                onPressed: () {
                  questionBankControllerNotifier.refresh();
                },
              ),
            ],
            title: const Text('Question Bank'),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              background: QuestionBankHeader(
                selectedType: questionBankControllerNotifier.currentBankType,
                onTypeChanged: (type) {
                  questionBankControllerNotifier.switchBankType(type);
                },
                searchController: _searchController,
                selectedGrade: questionBankController.value?.gradeFilter,
                selectedSubject: questionBankController.value?.subjectFilter,
                onSearchSubmitted: (value) {
                  questionBankControllerNotifier.search(value);
                },
                onSearchCleared: () {
                  _searchController.clear();
                  questionBankControllerNotifier.clearSearch();
                },
                onSearchChanged: () {
                  setState(() {}); // Update to show/hide clear button
                },
                onGradeChanged: (value) {
                  questionBankControllerNotifier.setGradeFilter(
                    value?.apiValue,
                  );
                },
                onSubjectChanged: (value) {
                  questionBankControllerNotifier.setSubjectFilter(value);
                },
                onClearFilters: () {
                  _searchController.clear();
                  questionBankControllerNotifier.clearFilters();
                  setState(() {});
                },
              ),
            ),
          ),
        ],
        body: questionBankController.easyWhen(
          data: (questionBankState) => RefreshIndicator(
            onRefresh: () async {
              await questionBankControllerNotifier.refresh();
            },
            child: questionBankState.questions.isEmpty
                ? _buildEmptyState(theme, questionBankState.currentBankType)
                : QuestionBankList(
                    questions: questionBankState.questions,
                    isPersonal:
                        questionBankState.currentBankType == BankType.personal,
                    isLoadingMore: questionBankState.isLoadingMore,
                    onView: (item) {
                      context.router.push(
                        QuestionDetailRoute(questionId: item.id),
                      );
                    },
                    onEdit: (item) {
                      context.router.push(
                        QuestionUpsertRoute(questionId: item.id),
                      );
                    },
                    onDelete: (item) => _showDeleteConfirmation(item),
                  ),
          ),
          loadingWidget: () => const QuestionBankLoading(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.router.push(QuestionUpsertRoute(questionId: null));
        },
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Question'),
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
              ref.context.router.navigate(
                QuestionUpsertRoute(questionId: null),
              );
            }
          : null,
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
