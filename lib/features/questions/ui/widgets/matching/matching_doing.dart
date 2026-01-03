import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/ui/widgets/question_card_wrapper.dart';
import 'package:datn_mobile/shared/widget/dropdown_field.dart';

/// Matching Question in Doing Mode
class MatchingDoing extends StatefulWidget {
  final MatchingQuestion question;
  final Map<String, String>? answers; // pairId -> selectedRightId
  final Function(Map<String, String>)? onAnswersChanged;

  const MatchingDoing({
    super.key,
    required this.question,
    this.answers,
    this.onAnswersChanged,
  });

  @override
  State<MatchingDoing> createState() => _MatchingDoingState();
}

class _MatchingDoingState extends State<MatchingDoing> {
  late Map<String, String?> _selectedAnswers;
  late List<String> _rightItems;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = Map.from(widget.answers ?? {});
    _rightItems = widget.question.data.pairs.map((pair) => pair.right).toList()
      ..shuffle();
  }

  void _selectMatch(String leftItem, String? rightItem) {
    setState(() {
      _selectedAnswers[leftItem] = rightItem;
    });
    widget.onAnswersChanged?.call(
      Map.from(
        _selectedAnswers,
      ).map((key, value) => MapEntry(key, value ?? '')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return QuestionCardWrapper(
      title: widget.question.title,
      titleImageUrl: widget.question.titleImageUrl,
      difficulty: widget.question.difficulty,
      points: widget.question.points,
      type: widget.question.type,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DOING MODE - Match the pairs:',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.question.data.pairs.map((pair) {
            return _buildMatchingPair(pair, theme);
          }),
        ],
      ),
    );
  }

  Widget _buildMatchingPair(MatchingPair pair, ThemeData theme) {
    const placeholder = 'Select match...';
    final currentValue = _selectedAnswers[pair.left] ?? placeholder;
    final dropdownItems = [placeholder, ..._rightItems];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_forward, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pair.left,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          DropdownField<String>(
            value: currentValue,
            items: dropdownItems,
            onChanged: (value) {
              if (value != null && value != placeholder) {
                _selectMatch(pair.left, value);
              } else {
                _selectMatch(pair.left, null);
              }
            },
          ),
        ],
      ),
    );
  }
}
