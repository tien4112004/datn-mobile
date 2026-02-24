import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_bank_item_entity.dart';
import 'package:AIPrimary/features/questions/states/question_generation_provider.dart';
import 'package:AIPrimary/features/questions/ui/widgets/detail/explanation_card.dart';
import 'package:AIPrimary/features/questions/ui/widgets/detail/question_content_card.dart';
import 'package:AIPrimary/features/questions/ui/widgets/detail/question_title_section.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_list_card.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class QuestionGenerateResultPage extends ConsumerStatefulWidget {
  const QuestionGenerateResultPage({super.key});

  @override
  ConsumerState<QuestionGenerateResultPage> createState() =>
      _QuestionGenerateResultPageState();
}

class _QuestionGenerateResultPageState
    extends ConsumerState<QuestionGenerateResultPage> {
  late final t = ref.watch(translationsPod);

  void _showDetailSheet(QuestionBankItemEntity item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      QuestionTitleSection(
                        question: item.question,
                        grade: item.grade?.name,
                        subject: item.subject?.name,
                      ),
                      QuestionContentCard(question: item.question),
                      if (item.question.explanation != null &&
                          item.question.explanation!.isNotEmpty)
                        ExplanationCard(
                          explanation: item.question.explanation!,
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(questionGenerationProvider).generatedQuestions;

    return Scaffold(
      backgroundColor: Themes.theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Themes.theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => context.router.maybePop(),
            ),
            title: Text(
              t.generate.questionGenerateResult.title(count: questions.length),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverList.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final item = questions[index];
                return QuestionListCard(
                  item: item,
                  showActions: true,
                  onTap: () => _showDetailSheet(item),
                  onView: () => _showDetailSheet(item),
                  onEdit: () => context.router.push(
                    QuestionUpdateRoute(questionId: item.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.router.maybePop(),
                  child: Text(t.generate.questionGenerateResult.generateMore),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () =>
                      context.router.push(const QuestionBankRoute()),
                  child: Text(t.questionBank.title),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
