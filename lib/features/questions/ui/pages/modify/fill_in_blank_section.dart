import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:datn_mobile/features/questions/ui/widgets/modify/segment_item_card.dart';

/// Section for managing fill-in-blank question segments
class FillInBlankSection extends StatefulWidget {
  final List<SegmentData> segments;
  final bool caseSensitive;
  final ValueChanged<List<SegmentData>> onSegmentsChanged;
  final ValueChanged<bool> onCaseSensitiveChanged;

  const FillInBlankSection({
    super.key,
    required this.segments,
    required this.caseSensitive,
    required this.onSegmentsChanged,
    required this.onCaseSensitiveChanged,
  });

  @override
  State<FillInBlankSection> createState() => _FillInBlankSectionState();
}

class _FillInBlankSectionState extends State<FillInBlankSection> {
  late List<SegmentData> _segments;

  @override
  void initState() {
    super.initState();
    _segments = List.from(widget.segments);
  }

  void _addTextSegment() {
    setState(() {
      _segments.add(
        SegmentData(
          type: SegmentType.text,
          content: '',
          acceptableAnswers: null,
        ),
      );
    });
    widget.onSegmentsChanged(_segments);
  }

  void _addBlankSegment() {
    setState(() {
      _segments.add(
        SegmentData(
          type: SegmentType.blank,
          content: 'blank',
          acceptableAnswers: [],
        ),
      );
    });
    widget.onSegmentsChanged(_segments);
  }

  void _removeSegment(int index) {
    if (_segments.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least 1 segment is required'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _segments.removeAt(index);
    });
    widget.onSegmentsChanged(_segments);
  }

  void _updateSegment(
    int index, {
    String? content,
    List<String>? acceptableAnswers,
  }) {
    setState(() {
      _segments[index] = SegmentData(
        type: _segments[index].type,
        content: content ?? _segments[index].content,
        acceptableAnswers:
            acceptableAnswers ?? _segments[index].acceptableAnswers,
      );
    });
    widget.onSegmentsChanged(_segments);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _buildSectionHeader(
          context,
          'Fill in the Blank Segments',
          'Build your question with text and blank segments',
        ),
        const SizedBox(height: 16),

        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Create a question by alternating text and blank segments. Text segments display static content, while blanks require student input.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Segments list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _segments.length,
          itemBuilder: (context, index) {
            return SegmentItemCard(
              key: ValueKey('segment_$index'),
              index: index,
              type: _segments[index].type,
              content: _segments[index].content,
              acceptableAnswers: _segments[index].acceptableAnswers,
              canRemove: _segments.length > 1,
              onRemove: () => _removeSegment(index),
              onContentChanged: (value) =>
                  _updateSegment(index, content: value),
              onAcceptableAnswersChanged: (value) =>
                  _updateSegment(index, acceptableAnswers: value),
            );
          },
        ),

        // Add segment buttons
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addTextSegment,
                icon: const Icon(Icons.text_fields_outlined),
                label: const Text('Add Text'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addBlankSegment,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Add Blank'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Case sensitive toggle
        SwitchListTile(
          value: widget.caseSensitive,
          onChanged: widget.onCaseSensitiveChanged,
          title: Text(
            'Case Sensitive',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            'Answers must match exact capitalization',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),

        // Validation hint
        if (!_hasAtLeastOneBlank())
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
                    'Please add at least one blank segment',
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

  bool _hasAtLeastOneBlank() {
    return _segments.any((segment) => segment.type == SegmentType.blank);
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

/// Data class for fill-in-blank segment
class SegmentData {
  final SegmentType type;
  final String content;
  final List<String>? acceptableAnswers;

  SegmentData({
    required this.type,
    required this.content,
    this.acceptableAnswers,
  });
}
