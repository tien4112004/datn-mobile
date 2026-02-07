import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Multiple Choice Question in Doing Mode (Student taking exam)
/// Enhanced with Material 3 design principles
class MultipleChoiceDoing extends ConsumerStatefulWidget {
  final MultipleChoiceQuestion question;
  final String? selectedAnswer;
  final Function(String)? onAnswerSelected;

  const MultipleChoiceDoing({
    super.key,
    required this.question,
    this.selectedAnswer,
    this.onAnswerSelected,
  });

  @override
  ConsumerState<MultipleChoiceDoing> createState() =>
      _MultipleChoiceDoingState();
}

class _MultipleChoiceDoingState extends ConsumerState<MultipleChoiceDoing> {
  String? _selectedOptionId;

  @override
  void initState() {
    super.initState();
    _selectedOptionId = widget.selectedAnswer;
  }

  void _selectOption(String optionId) {
    setState(() {
      _selectedOptionId = optionId;
    });
    widget.onAnswerSelected?.call(optionId);
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
              color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 16,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  t
                      .questionBank
                      .viewing
                      .viewingMode, // Or add specific "Select your answer"
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...widget.question.data.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedOptionId == option.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSelectableOption(option, index, isSelected, theme),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSelectableOption(
    MultipleChoiceOption option,
    int index,
    bool isSelected,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectOption(option.id),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Option letter badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Option text
                Expanded(
                  child: Text(
                    option.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline,
                      width: 2,
                    ),
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: colorScheme.onPrimary,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
