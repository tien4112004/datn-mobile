import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';
import 'matching_content_widget.dart';

/// Matching Question in Viewing Mode
class MatchingViewing extends ConsumerWidget {
  final MatchingQuestion question;

  /// When false, hides the header (title, badges) to avoid duplication
  final bool showHeader;

  const MatchingViewing({
    super.key,
    required this.question,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);

    return QuestionCardWrapper(
      title: question.title,
      titleImageUrl: question.titleImageUrl,
      difficulty: question.difficulty,
      type: question.type,
      showHeader: showHeader,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.questionBank.viewing.viewingModeCorrectMatches,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...question.data.pairs.map((pair) {
            return _buildPairDisplay(pair, theme);
          }),
        ],
      ),
    );
  }

  Widget _buildPairDisplay(MatchingPair pair, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.green.withValues(alpha: 0.05),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side content
          Expanded(
            child: MatchingContentWidget(
              text: pair.left,
              imageUrl: pair.leftImageUrl,
              backgroundColor: theme.colorScheme.surface,
              borderColor: Colors.green.shade200,
              borderWidth: 1,
            ),
          ),
          // Arrow separator
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Icon(Icons.arrow_forward, color: Colors.green, size: 28),
          ),
          // Right side content
          Expanded(
            child: MatchingContentWidget(
              text: pair.right,
              imageUrl: pair.rightImageUrl,
              backgroundColor: theme.colorScheme.surface,
              borderColor: Colors.green.shade200,
              borderWidth: 1,
            ),
          ),
        ],
      ),
    );
  }
}
