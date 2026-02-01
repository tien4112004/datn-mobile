import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/questions/ui/widgets/modify/option_item_card.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

/// Section for managing multiple choice question options
class MultipleChoiceSection extends ConsumerStatefulWidget {
  final List<MultipleChoiceOptionData> options;
  final bool shuffleOptions;
  final ValueChanged<List<MultipleChoiceOptionData>> onOptionsChanged;
  final ValueChanged<bool> onShuffleChanged;

  const MultipleChoiceSection({
    super.key,
    required this.options,
    required this.shuffleOptions,
    required this.onOptionsChanged,
    required this.onShuffleChanged,
  });

  @override
  ConsumerState<MultipleChoiceSection> createState() =>
      _MultipleChoiceSectionState();
}

class _MultipleChoiceSectionState extends ConsumerState<MultipleChoiceSection> {
  late List<MultipleChoiceOptionData> _options;

  @override
  void initState() {
    super.initState();
    _options = List.from(widget.options);
  }

  void _addOption() {
    setState(() {
      _options.add(
        MultipleChoiceOptionData(text: '', imageUrl: null, isCorrect: false),
      );
    });
    widget.onOptionsChanged(_options);
  }

  void _removeOption(int index) {
    if (_options.length <= 2) {
      final t = ref.read(translationsPod);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.questionBank.multipleChoice.minOptionsRequired),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _options.removeAt(index);
    });
    widget.onOptionsChanged(_options);
  }

  void _updateOption(
    int index, {
    String? text,
    String? imageUrl,
    bool? isCorrect,
  }) {
    setState(() {
      _options[index] = MultipleChoiceOptionData(
        text: text ?? _options[index].text,
        imageUrl: imageUrl ?? _options[index].imageUrl,
        isCorrect: isCorrect ?? _options[index].isCorrect,
      );
    });
    widget.onOptionsChanged(_options);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _buildSectionHeader(
          context,
          t.questionBank.multipleChoice.title,
          t.questionBank.multipleChoice.subtitle,
        ),
        const SizedBox(height: 16),

        // Options list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _options.length,
          itemBuilder: (context, index) {
            return OptionItemCard(
              key: ValueKey('option_$index'),
              index: index,
              text: _options[index].text,
              imageUrl: _options[index].imageUrl,
              isCorrect: _options[index].isCorrect,
              canRemove: _options.length > 2,
              isMultipleSelect: false,
              onRemove: () => _removeOption(index),
              onTextChanged: (value) => _updateOption(index, text: value),
              onImageUrlChanged: (value) => _updateOption(
                index,
                imageUrl: value?.isEmpty == true ? null : value,
              ),
              onCorrectChanged: (value) =>
                  _updateOption(index, isCorrect: value),
            );
          },
        ),

        // Add option button
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addOption,
            icon: const Icon(Icons.add_circle_outline),
            label: Text(t.questionBank.multipleChoice.addOption),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Shuffle options toggle
        SwitchListTile(
          value: widget.shuffleOptions,
          onChanged: widget.onShuffleChanged,
          title: Text(
            t.questionBank.multipleChoice.shuffleOptions,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            t.questionBank.multipleChoice.shuffleDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),

        // Validation hint
        if (!_hasCorrectAnswer())
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: colorScheme.onErrorContainer,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t.questionBank.multipleChoice.markCorrect,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  bool _hasCorrectAnswer() {
    return _options.any((option) => option.isCorrect);
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Divider(color: colorScheme.outlineVariant),
      ],
    );
  }
}

/// Data class for multiple choice option
class MultipleChoiceOptionData {
  final String text;
  final String? imageUrl;
  final bool isCorrect;

  MultipleChoiceOptionData({
    required this.text,
    this.imageUrl,
    required this.isCorrect,
  });
}
