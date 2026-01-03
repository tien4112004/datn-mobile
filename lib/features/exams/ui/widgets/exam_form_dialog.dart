import 'package:datn_mobile/features/exams/domain/entity/exam_entity.dart';
import 'package:datn_mobile/features/exams/domain/entity/exam_enums.dart';
import 'package:datn_mobile/features/exams/states/controller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ExamFormDialog extends ConsumerStatefulWidget {
  final ExamEntity? exam;

  const ExamFormDialog({super.key, this.exam});

  @override
  ConsumerState<ExamFormDialog> createState() => _ExamFormDialogState();
}

class _ExamFormDialogState extends ConsumerState<ExamFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _topicController;
  late final TextEditingController _timeLimitController;

  GradeLevel _selectedGradeLevel = GradeLevel.k;
  Difficulty _selectedDifficulty = Difficulty.medium;

  bool get _isEditing => widget.exam != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.exam?.title);
    _descriptionController = TextEditingController(
      text: widget.exam?.description,
    );
    _topicController = TextEditingController(text: widget.exam?.topic);
    _timeLimitController = TextEditingController(
      text: widget.exam?.timeLimitMinutes?.toString(),
    );

    if (widget.exam != null) {
      _selectedGradeLevel = widget.exam!.gradeLevel;
      _selectedDifficulty = widget.exam!.difficulty;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _topicController.dispose();
    _timeLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isEditing ? LucideIcons.pencil : LucideIcons.plus,
                          color: colorScheme.onPrimaryContainer,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _isEditing ? 'Edit Exam' : 'Create New Exam',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(LucideIcons.x),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Exam Title *',
                      hintText: 'e.g., Mathematics Final Exam - Grade 1',
                      prefixIcon: const Icon(LucideIcons.fileText),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter exam title';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _topicController,
                    decoration: InputDecoration(
                      labelText: 'Topic *',
                      hintText: 'e.g., Mathematics, Science',
                      prefixIcon: const Icon(LucideIcons.bookOpen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter topic';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                    enabled: !_isEditing,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Brief description of the exam',
                      prefixIcon: const Icon(LucideIcons.fileText),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<GradeLevel>(
                    initialValue: _selectedGradeLevel,
                    decoration: InputDecoration(
                      labelText: 'Grade Level *',
                      prefixIcon: const Icon(LucideIcons.graduationCap),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: GradeLevel.values
                        .map(
                          (grade) => DropdownMenuItem(
                            value: grade,
                            child: Text(grade.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: _isEditing
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _selectedGradeLevel = value);
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Difficulty>(
                    initialValue: _selectedDifficulty,
                    decoration: InputDecoration(
                      labelText: 'Difficulty *',
                      prefixIcon: const Icon(LucideIcons.trendingUp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: Difficulty.values
                        .map(
                          (difficulty) => DropdownMenuItem(
                            value: difficulty,
                            child: Row(
                              children: [
                                Icon(
                                  _getDifficultyIcon(difficulty),
                                  size: 18,
                                  color: _getDifficultyColor(difficulty),
                                ),
                                const SizedBox(width: 8),
                                Text(difficulty.displayName),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _isEditing
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _selectedDifficulty = value);
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _timeLimitController,
                    decoration: InputDecoration(
                      labelText: 'Time Limit (minutes)',
                      hintText: 'e.g., 60',
                      prefixIcon: const Icon(LucideIcons.clock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final minutes = int.tryParse(value);
                        if (minutes == null || minutes <= 0) {
                          return 'Please enter a valid time limit';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _saveExam,
                        icon: Icon(
                          _isEditing ? LucideIcons.check : LucideIcons.plus,
                          size: 18,
                        ),
                        label: Text(_isEditing ? 'Save' : 'Create'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getDifficultyIcon(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return LucideIcons.trendingDown;
      case Difficulty.medium:
        return LucideIcons.minus;
      case Difficulty.hard:
        return LucideIcons.trendingUp;
    }
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  Future<void> _saveExam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final topic = _topicController.text.trim();
    final timeLimitText = _timeLimitController.text.trim();
    final timeLimit = timeLimitText.isNotEmpty
        ? int.tryParse(timeLimitText)
        : null;

    try {
      if (_isEditing) {
        await ref
            .read(updateExamControllerProvider.notifier)
            .updateExam(
              examId: widget.exam!.examId,
              title: title,
              description: description.isEmpty ? null : description,
              timeLimitMinutes: timeLimit,
            );
      } else {
        await ref
            .read(createExamControllerProvider.notifier)
            .createExam(
              title: title,
              description: description.isEmpty ? null : description,
              topic: topic,
              gradeLevel: _selectedGradeLevel,
              difficulty: _selectedDifficulty,
              timeLimitMinutes: timeLimit,
            );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Exam updated successfully'
                  : 'Exam created successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
