import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/states/question_bank_provider.dart';
import 'package:datn_mobile/features/questions/ui/widgets/detail/question_info_header.dart';
import 'package:datn_mobile/features/questions/ui/widgets/detail/question_metadata_section.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:datn_mobile/shared/widget/enhanced_empty_state.dart';
import 'package:datn_mobile/shared/widget/enhanced_error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Import viewing widgets
import 'package:datn_mobile/features/questions/ui/widgets/multiple_choice/multiple_choice_viewing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/matching/matching_viewing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/fill_in_blank/fill_in_blank_viewing.dart';
import 'package:datn_mobile/features/questions/ui/widgets/open_ended/open_ended_viewing.dart';

/// Question Detail Page - displays complete question information in view mode
/// with an edit toggle in the app bar that navigates to QuestionUpsertPage.
///
/// Follows Material Design 3 guidelines and Flutter best practices.
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(questionBankProvider.notifier)
          .getQuestionById(widget.questionId);
    });
  }

  void _navigateToEdit() {
    HapticFeedback.lightImpact();
    context.router.push(QuestionUpsertRoute(questionId: widget.questionId));
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
          if (questionBankState.questions.isEmpty) {
            return _buildEmptyState(context);
          }

          final questionItem = questionBankState.questions.first;
          final question = questionItem.question;

          return CustomScrollView(
            slivers: [
              // Sticky App Bar
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: colorScheme.surface,
                surfaceTintColor: colorScheme.surfaceTint,
                leading: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft),
                  onPressed: () => context.router.maybePop(),
                ),
                title: Text(
                  'Question Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                actions: [
                  // Edit Button
                  IconButton(
                    icon: const Icon(LucideIcons.pencil, size: 20),
                    onPressed: _navigateToEdit,
                    tooltip: 'Edit Question',
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // Question Info Header
              SliverToBoxAdapter(child: QuestionInfoHeader(question: question)),

              // Question Content Section
              SliverToBoxAdapter(
                child: _buildQuestionContent(context, question),
              ),

              // Explanation Section (if available)
              if (question.explanation != null &&
                  question.explanation!.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildExplanationSection(
                    context,
                    question.explanation!,
                  ),
                ),

              // Metadata Section
              SliverToBoxAdapter(
                child: QuestionMetadataSection(
                  createdAt: questionItem.createdAt,
                  updatedAt: questionItem.updatedAt,
                  ownerId: questionItem.ownerId,
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
        loadingWidget: () => _buildLoadingState(context),
        errorWidget: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  Widget _buildQuestionContent(BuildContext context, BaseQuestion question) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Question Content',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const Divider(height: 1),
          _buildTypeSpecificContent(question),
        ],
      ),
    );
  }

  Widget _buildTypeSpecificContent(BaseQuestion question) {
    // Use existing viewing widgets based on question type
    if (question is MultipleChoiceQuestion) {
      return MultipleChoiceViewing(question: question);
    } else if (question is MatchingQuestion) {
      return MatchingViewing(question: question);
    } else if (question is FillInBlankQuestion) {
      return FillInBlankViewing(question: question);
    } else if (question is OpenEndedQuestion) {
      return OpenEndedViewing(question: question);
    }

    return const SizedBox.shrink();
  }

  Widget _buildExplanationSection(BuildContext context, String explanation) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  LucideIcons.lightbulb,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Explanation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              explanation,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              fontWeight: FontWeight.w600,
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

  Widget _buildErrorState(BuildContext context, Object error) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.router.maybePop(),
          ),
          title: Text(
            'Question Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        SliverFillRemaining(
          child: EnhancedErrorState(
            message: 'Failed to load question',
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

  Widget _buildEmptyState(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.router.maybePop(),
          ),
          title: Text(
            'Question Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
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
