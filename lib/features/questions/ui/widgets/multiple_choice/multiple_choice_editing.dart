import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Multiple Choice Question in Editing Mode
class MultipleChoiceEditing extends ConsumerStatefulWidget {
  final MultipleChoiceQuestion question;
  final Function(MultipleChoiceQuestion)? onUpdate;

  const MultipleChoiceEditing({
    super.key,
    required this.question,
    this.onUpdate,
  });

  @override
  ConsumerState<MultipleChoiceEditing> createState() =>
      _MultipleChoiceEditingState();
}

class _MultipleChoiceEditingState extends ConsumerState<MultipleChoiceEditing> {
  late List<MultipleChoiceOption> _options;
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _options = List.from(widget.question.data.options);
    _titleController.text = widget.question.title;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _toggleCorrect(int index) {
    setState(() {
      _options[index] = _options[index].copyWith(
        isCorrect: !_options[index].isCorrect,
      );
    });
  }

  void _addOption() {
    final t = ref.read(translationsPod);
    setState(() {
      _options.add(
        MultipleChoiceOption(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: t.questionBank.multipleChoice.newOption,
          isCorrect: false,
        ),
      );
    });
  }

  void _removeOption(int index) {
    if (_options.length > 2) {
      setState(() {
        _options.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);

    return QuestionCardWrapper(
      title: widget.question.title,
      titleImageUrl: widget.question.titleImageUrl,
      difficulty: widget.question.difficulty,
      type: widget.question.type,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            QuestionMode.editing.getLocalizedName(t).toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.purple,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.questionBank.multipleChoice.subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ..._options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return _buildEditableOption(option, index, theme, t);
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add),
                label: Text(t.questionBank.multipleChoice.addOption),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableOption(
    MultipleChoiceOption option,
    int index,
    ThemeData theme,
    Translations t,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: option.isCorrect ? Colors.green : Colors.grey[300]!,
          width: option.isCorrect ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: option.isCorrect ? Colors.green.withValues(alpha: 0.05) : null,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: option.isCorrect ? Colors.green : Colors.grey[300],
          child: Text(
            String.fromCharCode(65 + index), // A, B, C, D
            style: TextStyle(
              color: option.isCorrect ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: TextFormField(
          initialValue: option.text,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: t.questionBank.multipleChoice.enterOptionText,
          ),
          onChanged: (value) {
            _options[index] = option.copyWith(text: value);
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                option.isCorrect
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: option.isCorrect ? Colors.green : Colors.grey,
              ),
              onPressed: () => _toggleCorrect(index),
              tooltip: t.questionBank.multipleChoice.markCorrect,
            ),
            if (_options.length > 2)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeOption(index),
                tooltip: t.questionBank.multipleChoice.removeTooltip,
              ),
          ],
        ),
      ),
    );
  }
}
