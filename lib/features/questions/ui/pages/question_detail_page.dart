import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/states/question_bank_provider.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:datn_mobile/shared/widget/enhanced_empty_state.dart';
import 'package:datn_mobile/shared/widget/enhanced_error_state.dart';
import 'package:datn_mobile/shared/widgets/question_badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Import detail widgets
import 'package:datn_mobile/features/questions/ui/widgets/detail/question_title_section.dart';
import 'package:datn_mobile/features/questions/ui/widgets/detail/question_content_card.dart';
import 'package:datn_mobile/features/questions/ui/widgets/detail/stats_section.dart';
import 'package:datn_mobile/features/questions/ui/widgets/detail/explanation_card.dart';
import 'package:datn_mobile/features/questions/ui/widgets/detail/question_metadata_section.dart';

/// Question Detail Page - displays complete question information in view mode
///
/// Features:
/// - Material Design 3 components and styling
/// - Enhanced visual hierarchy with proper typography
/// - Modular widget composition for reusability
/// - Responsive loading, error, and empty states
/// - Edit navigation with haptic feedback
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
          if (questionBankState.selectedQuestion == null) {
            return _buildEmptyState(context);
          }

          final questionItem = questionBankState.selectedQuestion!;
          final question = questionItem.question;

          return CustomScrollView(
            slivers: [
              // Sticky App Bar
              _buildAppBar(context, theme, colorScheme),

              // Question Title Section
              SliverToBoxAdapter(
                child: QuestionTitleSection(question: question),
              ),

              // Question Type & Difficulty Badges
              SliverToBoxAdapter(child: _buildBadgesSection(question)),

              // Question Content Card
              SliverToBoxAdapter(
                child: QuestionContentCard(question: question),
              ),

              // Stats Section
              SliverToBoxAdapter(child: StatsSection(question: question)),

              // Explanation Section (if available)
              if (question.explanation != null &&
                  question.explanation!.isNotEmpty)
                SliverToBoxAdapter(
                  child: ExplanationCard(explanation: question.explanation!),
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
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
        loadingWidget: () => _buildLoadingState(context),
        errorWidget: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  /// App Bar - Sticky header with back button and edit action
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

  /// Badges Section - Question Type & Difficulty chips
  Widget _buildBadgesSection(BaseQuestion question) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          QuestionTypeBadge(type: question.type, iconSize: 18, fontSize: 14),
          DifficultyBadge(
            difficulty: question.difficulty,
            iconSize: 18,
            fontSize: 14,
          ),
        ],
      ),
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
