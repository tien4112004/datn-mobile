import 'package:AIPrimary/features/assignments/domain/entity/assignment_draft_entity.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Card displaying a single matrix gap (questions missing from draft).
class MatrixGapCard extends ConsumerWidget {
  final MatrixGapEntity gap;

  const MatrixGapCard({super.key, required this.gap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Topic + type badges row
            Wrap(
              spacing: 8,
              children: [
                _Chip(label: gap.topic, color: cs.primaryContainer),
                _Chip(label: gap.difficulty, color: cs.secondaryContainer),
                _Chip(label: gap.questionType, color: cs.tertiaryContainer),
              ],
            ),
            const SizedBox(height: 8),
            // Counts row
            Row(
              children: [
                _CountBadge(
                  label: t.assignments.draftReview.gapCard.required,
                  value: gap.requiredCount,
                  color: cs.onSurface,
                ),
                const SizedBox(width: 12),
                _CountBadge(
                  label: t.assignments.draftReview.gapCard.available,
                  value: gap.availableCount,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _CountBadge(
                  label: t.assignments.draftReview.gapCard.missing,
                  value: gap.gapCount,
                  color: cs.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _CountBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
