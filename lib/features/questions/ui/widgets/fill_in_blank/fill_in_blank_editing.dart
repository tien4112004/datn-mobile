import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/ui/widgets/question_card_wrapper.dart';

/// Fill in Blank Question in Editing Mode (Teacher creating/editing)
/// Enhanced with Material 3 design principles
class FillInBlankEditing extends StatefulWidget {
  final FillInBlankQuestion question;
  final Function(FillInBlankQuestion)? onUpdate;

  const FillInBlankEditing({super.key, required this.question, this.onUpdate});

  @override
  State<FillInBlankEditing> createState() => _FillInBlankEditingState();
}

class _FillInBlankEditingState extends State<FillInBlankEditing> {
  late List<BlankSegment> _segments;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _segments = List.from(widget.question.data.segments);

    for (var segment in _segments) {
      _controllers[segment.id] = TextEditingController(text: segment.content);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addTextSegment() {
    setState(() {
      final newSegment = BlankSegment(
        id: 't${DateTime.now().millisecondsSinceEpoch}',
        type: SegmentType.text,
        content: '',
      );
      _segments.add(newSegment);
      _controllers[newSegment.id] = TextEditingController();
    });
  }

  void _addBlankSegment() {
    setState(() {
      final newSegment = BlankSegment(
        id: 'b${DateTime.now().millisecondsSinceEpoch}',
        type: SegmentType.blank,
        content: '',
      );
      _segments.add(newSegment);
      _controllers[newSegment.id] = TextEditingController();
    });
  }

  void _removeSegment(int index) {
    if (_segments.length > 1) {
      setState(() {
        final segment = _segments[index];
        _controllers[segment.id]?.dispose();
        _controllers.remove(segment.id);
        _segments.removeAt(index);
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
      points: widget.question.points,
      type: widget.question.type,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
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
                  'Editing Mode - Create sentence with blanks',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Segments list
          ..._segments.asMap().entries.map((entry) {
            final index = entry.key;
            final segment = entry.value;
            return _buildEditableSegment(segment, index, theme);
          }),
          const SizedBox(height: 16),
          // Add buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addTextSegment,
                  icon: const Icon(Icons.text_fields),
                  label: const Text('Add Text'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.secondary,
                    side: BorderSide(color: colorScheme.secondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addBlankSegment,
                  icon: const Icon(Icons.space_bar),
                  label: const Text('Add Blank'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableSegment(
    BlankSegment segment,
    int index,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;
    final isBlank = segment.type == SegmentType.blank;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBlank
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBlank
              ? colorScheme.primary.withValues(alpha: 0.5)
              : colorScheme.outlineVariant,
          width: isBlank ? 2 : 1,
        ),
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
                  color: isBlank
                      ? colorScheme.primary
                      : colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isBlank ? Icons.space_bar : Icons.text_fields,
                      size: 14,
                      color: isBlank
                          ? colorScheme.onPrimary
                          : colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isBlank ? 'Blank ${_getBlankNumber(index)}' : 'Text',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isBlank
                            ? colorScheme.onPrimary
                            : colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_segments.length > 1)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                  onPressed: () => _removeSegment(index),
                  tooltip: 'Remove segment',
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controllers[segment.id],
            maxLines: isBlank ? 1 : 3,
            decoration: InputDecoration(
              labelText: isBlank ? 'Correct answer' : 'Text content',
              hintText: isBlank
                  ? 'Enter the correct answer for this blank'
                  : 'Enter text that appears in the sentence',
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
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getBlankNumber(int currentIndex) {
    int count = 0;
    for (int i = 0; i <= currentIndex; i++) {
      if (_segments[i].type == SegmentType.blank) {
        count++;
      }
    }
    return count;
  }
}
