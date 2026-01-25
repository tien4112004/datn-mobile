import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/questions/states/question_bank_provider.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:datn_mobile/shared/widgets/enhanced_empty_state.dart';
import 'package:datn_mobile/shared/widgets/enhanced_error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Import detail widgets
import 'package:datn_mobile/features/questions/ui/widgets/detail/question_title_section.dart';
import 'package:datn_mobile/features/questions/ui/widgets/detail/question_content_card.dart';
import 'package:datn_mobile/features/questions/ui/widgets/detail/explanation_card.dart';
import 'package:datn_mobile/features/questions/ui/widgets/detail/question_metadata_section.dart';

@RoutePage()
class QuestionDetailPage extends ConsumerStatefulWidget {
  final String questionId;

  const QuestionDetailPage({
    super.key,
    @PathParam('questionId') required this.questionId,
  });

  @override
  ConsumerState<QuestionDetailPage> createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends ConsumerState<QuestionDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load question data on page init
    ref.read(questionBankProvider.notifier).getQuestionById(widget.questionId);
  }

  void _navigateToEdit() async {
    HapticFeedback.lightImpact();
    await context.router.push(
      QuestionUpdateRoute(questionId: widget.questionId),
    );

    // Reload the question after returning from edit page
    if (mounted) {
      ref
          .read(questionBankProvider.notifier)
          .getQuestionById(widget.questionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final questionBankAsync = ref.watch(questionBankProvider);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: questionBankAsync.easyWhen(
        data: (questionBankState) {
          // Get the question from the state
          debugPrint(
            '[DEBUG] questionBankState.selectedQuestion ${questionBankState.selectedQuestion}',
          );
          if (questionBankState.selectedQuestion == null) {
            debugPrint('[DEBUG] Question not found, showing empty state');
            return _buildEmptyState(context);
          }

          final questionItem = questionBankState.selectedQuestion!;
          final question = questionItem.question;

          return CustomScrollView(
            slivers: [
              // Sticky App Bar
              _buildAppBar(context, theme, colorScheme),

              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with Header Chips (Type, Grade, Subject)
                      QuestionTitleSection(
                        question: question,
                        grade: questionItem.grade?.displayName,
                        subject: questionItem.subject?.displayName,
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Content Card
                    QuestionContentCard(question: question),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Explanation (if available)
                    if (question.explanation != null &&
                        question.explanation!.isNotEmpty) ...[
                      ExplanationCard(explanation: question.explanation!),
                      const SizedBox(height: 16),
                    ],

                    // Metadata Footer
                    QuestionMetadataSection(
                      createdAt: questionItem.createdAt,
                      updatedAt: questionItem.updatedAt,
                      ownerId: questionItem.ownerId,
                      chapter: questionItem.chapter,
                    ),
                  ],
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
        loadingWidget: () => _buildLoadingState(context),
        errorWidget: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  SliverAppBar _buildAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft),
        onPressed: () => context.router.maybePop(),
        tooltip: 'Back',
      ),
      title: Text(
        'Question Details',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.pencil, size: 20),
          onPressed: _navigateToEdit,
          tooltip: 'Edit Question',
          style: IconButton.styleFrom(foregroundColor: colorScheme.primary),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Loading State - Shows circular progress indicator
  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: colorScheme.surface,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.router.maybePop(),
          ),
          title: Text(
            'Question Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Loading question...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Error State - Uses EnhancedErrorState widget
  Widget _buildErrorState(BuildContext context, Object error) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: colorScheme.surface,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.router.maybePop(),
          ),
          title: Text(
            'Question Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SliverFillRemaining(
          child: EnhancedErrorState(
            message: 'Failed to load question',
            actionLabel: 'Retry',
            onRetry: () {
              ref
                  .read(questionBankProvider.notifier)
                  .getQuestionById(widget.questionId);
            },
          ),
        ),
      ],
    );
  }

  /// Empty State - Uses EnhancedEmptyState widget
  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: colorScheme.surface,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.router.maybePop(),
          ),
          title: Text(
            'Question Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SliverFillRemaining(
          child: EnhancedEmptyState(
            icon: LucideIcons.fileText,
            title: 'Question Not Found',
            message: 'The question you are looking for does not exist.',
          ),
        ),
      ],
    );
  }
}
