import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_bank_loading.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/questions/states/question_bank_provider.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_bank_item_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_bank_header.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_bank_list.dart';
import 'package:AIPrimary/shared/widgets/enhanced_empty_state.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
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
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questionBankProvider.notifier).loadQuestionsWithFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionBankController = ref.watch(questionBankProvider);
    final questionBankControllerNotifier = ref.watch(
      questionBankProvider.notifier,
    );
    final questionFilterState = ref.watch(questionBankFilterProvider);
    final t = ref.watch(translationsPod);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            floating: false,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: colorScheme.surface,
            leading: Semantics(
              label: t.questionBank.back,
              button: true,
              hint: 'Double tap to return to previous page',
              child: IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.router.maybePop();
                },
                tooltip: t.questionBank.back,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: t.questionBank.refresh,
                onPressed: () {
                  questionBankControllerNotifier.loadQuestionsWithFilter();
                },
              ),
            ],
            title: Text(
              t.questionBank.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 16),
              background: QuestionBankHeader(),
            ),
          ),
        ],
        body: questionBankController.easyWhen(
          data: (questionBankState) => RefreshIndicator(
            onRefresh: () async {
              await questionBankControllerNotifier.loadQuestionsWithFilter();
            },
            child: questionBankState.questions.isEmpty
                ? _buildEmptyState(theme, questionFilterState.bankType, t)
                : QuestionBankList(
                    questions: questionBankState.questions,
                    isPersonal:
                        questionFilterState.bankType == BankType.personal,
                    isLoadingMore: questionBankState.isLoadingMore,
                    onView: (item) {
                      context.router.push(
                        QuestionDetailRoute(questionId: item.id),
                      );
                    },
                    onEdit: (item) {
                      context.router.push(
                        QuestionUpdateRoute(questionId: item.id),
                      );
                    },
                    onDelete: (item) => _showDeleteConfirmation(item, t),
                  ),
          ),
          loadingWidget: () => const QuestionBankLoading(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.router.push(const QuestionCreateRoute());
        },
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded),
        label: Text(t.questionBank.addQuestion),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, BankType bankType, dynamic t) {
    final isPersonal = bankType == BankType.personal;

    return EnhancedEmptyState(
      icon: isPersonal ? Icons.quiz_outlined : Icons.public_outlined,
      title: isPersonal
          ? t.questionBank.emptyState.noQuestions
          : t.questionBank.emptyState.noPublicQuestions,
      message: isPersonal
          ? t.questionBank.emptyState.createFirst
          : t.questionBank.emptyState.tryAdjusting,
      actionLabel: isPersonal ? t.questionBank.createQuestion : null,
      onAction: isPersonal
          ? () {
              ref.context.router.navigate(const QuestionCreateRoute());
            }
          : null,
    );
  }

  void _showDeleteConfirmation(QuestionBankItemEntity item, dynamic t) {
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
          title: Text(t.questionBank.deleteDialog.title),
          content: Text(
            t.questionBank.deleteDialog.message(title: item.question.title),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t.questionBank.actions.cancel),
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
                  SnackBar(content: Text(t.questionBank.deleteDialog.success)),
                );
              },
              child: Text(t.questionBank.actions.delete),
            ),
          ],
        );
      },
    );
  }
}
