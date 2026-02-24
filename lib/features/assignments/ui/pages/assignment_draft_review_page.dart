import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/assignments/data/dto/api/assignment_create_request.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/features/assignments/states/controller_provider.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/question_card.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/generation/matrix_gap_card.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class AssignmentDraftReviewPage extends ConsumerWidget {
  const AssignmentDraftReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final draftAsync = ref.watch(assignmentGenerationControllerProvider);
    final draft = draftAsync.value;

    if (draft == null) {
      // Shouldn't happen, but safe fallback
      return Scaffold(
        appBar: AppBar(title: Text(t.assignments.draftReview.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final isComplete = draft.isComplete;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            title: Text(t.assignments.draftReview.title),
            leading: IconButton(
              icon: const Icon(LucideIcons.x),
              onPressed: () {
                ref
                    .read(assignmentGenerationControllerProvider.notifier)
                    .clearDraft();
                context.router.pop();
              },
            ),
          ),

          // ── Stats row ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _StatChip(
                    label: t.assignments.draftReview.totalQuestions(
                      n: draft.totalQuestions,
                    ),
                    icon: LucideIcons.fileText,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: t.assignments.draftReview.totalPoints(
                      n: draft.totalPoints.toStringAsFixed(
                        draft.totalPoints % 1 == 0 ? 0 : 1,
                      ),
                    ),
                    icon: LucideIcons.star,
                    color: Colors.amber,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? Colors.green.withValues(alpha: 0.15)
                          : cs.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isComplete
                          ? t.assignments.draftReview.complete
                          : t.assignments.draftReview.incomplete,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isComplete ? Colors.green[700] : cs.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Gaps section ─────────────────────────────────────────────────
          if (draft.gaps.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  t.assignments.draftReview.gaps(count: draft.gaps.length),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => MatrixGapCard(gap: draft.gaps[index]),
                childCount: draft.gaps.length,
              ),
            ),
          ] else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  t.assignments.draftReview.noGaps,
                  style: TextStyle(color: Colors.green[700]),
                ),
              ),
            ),

          // ── Questions section ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                t.assignments.detail.questions.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final aq = draft.questions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: QuestionCard(
                    question: aq.question,
                    questionNumber: index + 1,
                    isEditMode: false,
                  ),
                );
              },
              childCount: draft.questions.length,
            ),
          ),

          // Bottom padding for action bar
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        onRegenerate: () => context.router.pop(),
        onSave: () => _handleSave(context, ref),
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, WidgetRef ref) async {
    final draft = ref.read(assignmentGenerationControllerProvider).value;
    if (draft == null) return;

    final questions = draft.questions
        .map((q) => q.toRequest())
        .toList();

    final request = AssignmentCreateRequest(
      title: draft.title,
      description: draft.description,
      subject: draft.subject,
      grade: draft.grade,
      questions: questions,
    );

    try {
      final created = await ref
          .read(createAssignmentControllerProvider.notifier)
          .createAssignment(request);

      ref
          .read(assignmentGenerationControllerProvider.notifier)
          .clearDraft();

      if (context.mounted) {
        context.router.replace(
          AssignmentDetailRoute(assignmentId: created.assignmentId),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends ConsumerWidget {
  final VoidCallback onRegenerate;
  final VoidCallback onSave;

  const _BottomBar({required this.onRegenerate, required this.onSave});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final isSaving = ref.watch(createAssignmentControllerProvider).isLoading;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isSaving ? null : onRegenerate,
                child: Text(t.assignments.draftReview.regenerate),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: isSaving ? null : onSave,
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(t.assignments.draftReview.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
