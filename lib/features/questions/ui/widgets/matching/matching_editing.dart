import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/ui/widgets/question_card_wrapper.dart';

/// Matching Question in Editing Mode (Teacher creating/editing)
/// Enhanced with Material 3 design principles
class MatchingEditing extends StatefulWidget {
  final MatchingQuestion question;
  final Function(MatchingQuestion)? onUpdate;

  const MatchingEditing({super.key, required this.question, this.onUpdate});

  @override
  State<MatchingEditing> createState() => _MatchingEditingState();
}

class _MatchingEditingState extends State<MatchingEditing> {
  late List<MatchingPair> _pairs;
  final Map<String, TextEditingController> _leftControllers = {};
  final Map<String, TextEditingController> _rightControllers = {};

  @override
  void initState() {
    super.initState();
    _pairs = List.from(widget.question.data.pairs);

    for (var pair in _pairs) {
      _leftControllers[pair.id] = TextEditingController(text: pair.left);
      _rightControllers[pair.id] = TextEditingController(text: pair.right);
    }
  }

  @override
  void dispose() {
    for (var controller in _leftControllers.values) {
      controller.dispose();
    }
    for (var controller in _rightControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addPair() {
    setState(() {
      final newPair = MatchingPair(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        left: '',
        right: '',
      );
      _pairs.add(newPair);
      _leftControllers[newPair.id] = TextEditingController();
      _rightControllers[newPair.id] = TextEditingController();
    });
  }

  void _removePair(int index) {
    if (_pairs.length > 2) {
      setState(() {
        final pair = _pairs[index];
        _leftControllers[pair.id]?.dispose();
        _rightControllers[pair.id]?.dispose();
        _leftControllers.remove(pair.id);
        _rightControllers.remove(pair.id);
        _pairs.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              color: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Editing Mode - Create matching pairs',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._pairs.asMap().entries.map((entry) {
            final index = entry.key;
            final pair = entry.value;
            return _buildEditablePair(pair, index, theme);
          }),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _addPair,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add Pair'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditablePair(MatchingPair pair, int index, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Pair ${index + 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (_pairs.length > 2)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                  onPressed: () => _removePair(index),
                  tooltip: 'Remove pair',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Left Item',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _leftControllers[pair.id],
                      decoration: InputDecoration(
                        hintText: 'Enter left item',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLowest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outline),
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.compare_arrows,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Right Item',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _rightControllers[pair.id],
                      decoration: InputDecoration(
                        hintText: 'Enter right item',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLowest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outline),
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
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
