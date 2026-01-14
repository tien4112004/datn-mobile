import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:datn_mobile/shared/widget/flex_dropdown_field.dart';
import 'package:datn_mobile/shared/widgets/image_input_field.dart';

/// Section containing basic information fields for a question
class QuestionBasicInfoSection extends StatefulWidget {
  final String title;
  final QuestionType selectedType;
  final Difficulty selectedDifficulty;
  final int points;
  final String? titleImageUrl;
  final String explanation;
  final Grade? grade;
  final String? chapter;
  final Subject? subject;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<QuestionType> onTypeChanged;
  final ValueChanged<Difficulty> onDifficultyChanged;
  final ValueChanged<int> onPointsChanged;
  final ValueChanged<String?> onTitleImageChanged;
  final ValueChanged<String> onExplanationChanged;
  final ValueChanged<Grade?> onGradeChanged;
  final ValueChanged<String> onChapterChanged;
  final ValueChanged<Subject?> onSubjectChanged;

  const QuestionBasicInfoSection({
    super.key,
    required this.title,
    required this.selectedType,
    required this.selectedDifficulty,
    required this.points,
    this.titleImageUrl,
    required this.explanation,
    this.grade,
    this.chapter,
    this.subject,
    required this.onTitleChanged,
    required this.onTypeChanged,
    required this.onDifficultyChanged,
    required this.onPointsChanged,
    required this.onTitleImageChanged,
    required this.onExplanationChanged,
    required this.onGradeChanged,
    required this.onChapterChanged,
    required this.onSubjectChanged,
  });

  @override
  State<QuestionBasicInfoSection> createState() =>
      _QuestionBasicInfoSectionState();
}

class _QuestionBasicInfoSectionState extends State<QuestionBasicInfoSection> {
  late TextEditingController _titleController;
  late TextEditingController _pointsController;
  late TextEditingController _explanationController;
  late TextEditingController _chapterController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _pointsController = TextEditingController(text: widget.points.toString());
    _explanationController = TextEditingController(text: widget.explanation);
    _chapterController = TextEditingController(text: widget.chapter ?? '');
  }

  @override
  void didUpdateWidget(covariant QuestionBasicInfoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.title != oldWidget.title &&
        widget.title != _titleController.text) {
      _titleController.text = widget.title;
    }
    if (widget.points != oldWidget.points) {
      final pointsStr = widget.points.toString();
      if (pointsStr != _pointsController.text) {
        _pointsController.text = pointsStr;
      }
    }
    if (widget.explanation != oldWidget.explanation &&
        widget.explanation != _explanationController.text) {
      _explanationController.text = widget.explanation;
    }
    if (widget.chapter != oldWidget.chapter) {
      _chapterController.text = widget.chapter ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    _explanationController.dispose();
    _chapterController.dispose();
    super.dispose();
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
          'Basic Information',
          'Define the core properties of your question',
        ),
        const SizedBox(height: 16),

        // Title field (required)
        TextFormField(
          controller: _titleController,
          onChanged: widget.onTitleChanged,
          decoration: InputDecoration(
            labelText: 'Question Title *',
            hintText: 'Enter your question here',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
            helperText: 'This is the main question students will see',
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Question title is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Question type and difficulty dropdowns
        Row(
          children: [
            // Question type dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question Type *',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FlexDropdownField<QuestionType>(
                    value: widget.selectedType,
                    items: QuestionType.values,
                    onChanged: widget.onTypeChanged,
                    itemLabelBuilder: (type) => type.displayName,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Difficulty dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Difficulty *',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FlexDropdownField<Difficulty>(
                    value: widget.selectedDifficulty,
                    items: Difficulty.values,
                    onChanged: widget.onDifficultyChanged,
                    itemLabelBuilder: (diff) => diff.displayName,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Points field (optional)
        TextFormField(
          controller: _pointsController,
          onChanged: (value) {
            final parsedPoints = int.tryParse(value);
            if (parsedPoints != null) {
              widget.onPointsChanged(parsedPoints);
            }
          },
          decoration: InputDecoration(
            labelText: 'Points (Optional)',
            hintText: '0',
            prefixIcon: const Icon(Icons.star_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
            helperText: 'Leave empty or 0 for ungraded questions',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final points = int.tryParse(value);
              if (points == null || points < 0) {
                return 'Please enter a valid number';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Grade, Chapter, and Subject fields
        Row(
          children: [
            // Grade dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grade',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FlexDropdownField<Grade>(
                    value: widget.grade ?? Grade.grade1,
                    items: Grade.values,
                    onChanged: widget.onGradeChanged,
                    itemLabelBuilder: (grade) => grade.displayName,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Subject dropdown
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subject',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FlexDropdownField<Subject>(
                    value: widget.subject ?? Subject.english,
                    items: Subject.values,
                    onChanged: widget.onSubjectChanged,
                    itemLabelBuilder: (subject) => subject.displayName,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Chapter field (text input)
        TextFormField(
          controller: _chapterController,
          onChanged: widget.onChapterChanged,
          decoration: InputDecoration(
            labelText: 'Chapter (Optional)',
            hintText: 'e.g., Chapter 5',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),

        // Title image (optional) - upload or URL
        ImageInputField(
          key: ValueKey(widget.titleImageUrl),
          initialValue: widget.titleImageUrl,
          onChanged: widget.onTitleImageChanged,
          label: 'Question Image',
          hint: 'https://example.com/image.jpg',
          isRequired: false,
        ),
        const SizedBox(height: 16),

        // Explanation field (optional)
        TextFormField(
          controller: _explanationController,
          onChanged: widget.onExplanationChanged,
          decoration: InputDecoration(
            labelText: 'Explanation (Optional)',
            hintText: 'Explain why this is the correct answer...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(16),
            helperText: 'This will be shown after students answer',
          ),
          maxLines: 4,
        ),
      ],
    );
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
