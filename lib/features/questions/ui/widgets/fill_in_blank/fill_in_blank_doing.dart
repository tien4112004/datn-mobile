import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fill in Blank Question in Doing Mode
/// Enhanced with Material 3 design principles
class FillInBlankDoing extends ConsumerStatefulWidget {
  final FillInBlankQuestion question;
  final Map<String, String>? answers;
  final Function(Map<String, String>)? onAnswersChanged;

  const FillInBlankDoing({
    super.key,
    required this.question,
    this.answers,
    this.onAnswersChanged,
  });

  @override
  ConsumerState<FillInBlankDoing> createState() => _FillInBlankDoingState();
}

class _FillInBlankDoingState extends ConsumerState<FillInBlankDoing> {
  late Map<String, TextEditingController> _controllers;
  late Map<String, FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    _focusNodes = {};

    for (var segment in widget.question.data.segments) {
      if (segment.type == SegmentType.blank) {
        _controllers[segment.id] = TextEditingController(
          text: widget.answers?[segment.id] ?? '',
        );
        _focusNodes[segment.id] = FocusNode();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onAnswerChanged() {
    final answers = _controllers.map(
      (id, controller) => MapEntry(id, controller.text),
    );
    widget.onAnswersChanged?.call(answers);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return QuestionCardWrapper(
      title: widget.question.title,
      titleImageUrl: widget.question.titleImageUrl,
      difficulty: widget.question.difficulty,
      type: widget.question.type,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              // color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  t
                      .questionBank
                      .fillInBlank
                      .title, // Or add a specific "Fill in blanks" key
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: widget.question.data.segments.map((segment) {
              if (segment.type == SegmentType.text) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    segment.content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                );
              } else {
                return Container(
                  constraints: const BoxConstraints(
                    minWidth: 120,
                    maxWidth: 200,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextField(
                    controller: _controllers[segment.id],
                    focusNode: _focusNodes[segment.id],
                    onChanged: (_) => _onAnswerChanged(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: t.questionBank.fillInBlank.blankHint,
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLowest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              }
            }).toList(),
          ),
        ],
      ),
    );
  }
}
