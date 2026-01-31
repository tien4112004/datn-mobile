import 'package:flutter/material.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_entity.dart';
import 'package:AIPrimary/features/questions/ui/widgets/question_card_wrapper.dart';
import 'package:AIPrimary/features/questions/ui/widgets/fill_in_blank/widgets/editing_header.dart';
import 'package:AIPrimary/features/questions/ui/widgets/fill_in_blank/widgets/segment_item.dart';
import 'package:AIPrimary/features/questions/ui/widgets/fill_in_blank/widgets/add_segment_controls.dart';

/// Fill in Blank Question in Editing Mode (Teacher creating/editing)
/// Enhanced with Material 3 design principles
/// Refactored into smaller, reusable components
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
    return QuestionCardWrapper(
      title: widget.question.title,
      titleImageUrl: widget.question.titleImageUrl,
      difficulty: widget.question.difficulty,
      type: widget.question.type,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Editing header
          const EditingHeader(),
          const SizedBox(height: 16),

          // Segments list
          ..._segments.asMap().entries.map((entry) {
            final index = entry.key;
            final segment = entry.value;
            return SegmentItem(
              key: ValueKey(segment.id),
              segment: segment,
              index: index,
              blankNumber: _getBlankNumber(index),
              controller: _controllers[segment.id]!,
              onRemove: () => _removeSegment(index),
              canRemove: _segments.length > 1,
            );
          }),

          const SizedBox(height: 16),

          // Add segment controls
          AddSegmentControls(
            onAddText: _addTextSegment,
            onAddBlank: _addBlankSegment,
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
