import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Open Ended Question in Doing Mode
/// Enhanced with Material 3 design principles
class OpenEndedDoing extends ConsumerStatefulWidget {
  final OpenEndedQuestion question;
  final String? answer;
  final Function(String)? onAnswerChanged;

  const OpenEndedDoing({
    super.key,
    required this.question,
    this.answer,
    this.onAnswerChanged,
  });

  @override
  ConsumerState<OpenEndedDoing> createState() => _OpenEndedDoingState();
}

class _OpenEndedDoingState extends ConsumerState<OpenEndedDoing> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.answer ?? '');
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxLength = widget.question.data.maxLength;

    return QuestionCardWrapper(
      title: widget.question.title,
      titleImageUrl: widget.question.titleImageUrl,
      difficulty: widget.question.difficulty,
      type: widget.question.type,
      showBadges: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: 8,
            minLines: 6,
            maxLength: maxLength,
            onChanged: (value) => widget.onAnswerChanged?.call(value),
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            decoration: InputDecoration(
              hintText: t.questionBank.openEnded.typeAnswer,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLowest,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              counterStyle: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (maxLength != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _controller.text.length / maxLength,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _controller.text.length > maxLength * 0.9
                    ? Colors.orange
                    : colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ],
      ),
    );
  }
}
