import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/ui/widgets/question_card_wrapper.dart';

/// Multiple Choice Question in Editing Mode
class MultipleChoiceEditing extends StatefulWidget {
  final MultipleChoiceQuestion question;
  final Function(MultipleChoiceQuestion)? onUpdate;

  const MultipleChoiceEditing({
    super.key,
    required this.question,
    this.onUpdate,
  });

  @override
  State<MultipleChoiceEditing> createState() => _MultipleChoiceEditingState();
}

class _MultipleChoiceEditingState extends State<MultipleChoiceEditing> {
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
    setState(() {
      _options.add(
        MultipleChoiceOption(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'New option',
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
            'EDITING MODE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.purple,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Options (tap to mark as correct):',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ..._options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return _buildEditableOption(option, index, theme);
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add),
                label: const Text('Add Option'),
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
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter option text',
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
              tooltip: 'Mark as correct',
            ),
            if (_options.length > 2)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeOption(index),
                tooltip: 'Remove option',
              ),
          ],
        ),
      ),
    );
  }
}
