import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/features/questions/ui/widgets/detail/question_content_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Page for editing a question within an assignment context.
///
/// Features:
/// - Always allows editing points
/// - For bank questions: read-only question content with preview
/// - For new questions: full edit capability (future enhancement)
/// - Delete functionality
///
/// Returns updated AssignmentQuestionEntity or null if deleted
@RoutePage()
class AssignmentQuestionEditPage extends ConsumerStatefulWidget {
  /// The question entity to edit
  final AssignmentQuestionEntity questionEntity;

  /// Question number for display (1-indexed)
  final int questionNumber;

  const AssignmentQuestionEditPage({
    super.key,
    required this.questionEntity,
    required this.questionNumber,
  });

  @override
  ConsumerState<AssignmentQuestionEditPage> createState() =>
      _AssignmentQuestionEditPageState();
}

class _AssignmentQuestionEditPageState
    extends ConsumerState<AssignmentQuestionEditPage> {
  late TextEditingController _pointsController;
  late double _currentPoints;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _currentPoints = widget.questionEntity.points;
    _pointsController = TextEditingController(
      text: _currentPoints.toStringAsFixed(0),
    );

    _pointsController.addListener(() {
      final newValue = double.tryParse(_pointsController.text) ?? 0.0;
      if (newValue != _currentPoints) {
        setState(() {
          _hasUnsavedChanges = true;
          _currentPoints = newValue;
        });
      }
    });
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  void _handleSave() {
    // Validate points
    if (_currentPoints <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Points must be greater than 0')),
      );
      return;
    }

    // Create updated entity
    final updatedEntity = widget.questionEntity.copyWith(
      points: _currentPoints,
    );

    // Return to previous screen with updated entity
    Navigator.pop(context, updatedEntity);
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          icon: Icon(LucideIcons.circle, color: colorScheme.error, size: 32),
          title: const Text('Delete Question'),
          content: Text(
            'Are you sure you want to remove question ${widget.questionNumber} from this assignment?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      // Return special value to indicate deletion
      Navigator.pop(context, 'DELETE');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final question = widget.questionEntity.question;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Question ${widget.questionNumber}'),
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            // Delete button
            IconButton(
              icon: Icon(LucideIcons.trash2, color: colorScheme.error),
              onPressed: _handleDelete,
              tooltip: 'Delete Question',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Points Section (Always Editable)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.target,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Points',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _pointsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Points for this question',
                          suffixText: 'pts',
                          helperText: 'Points must be greater than 0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(LucideIcons.hash),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Question Preview Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            QuestionType.getIcon(question.type),
                            color: QuestionType.getColor(question.type),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            widget.questionEntity.isNewQuestion
                                ? 'Custom Question'
                                : 'Question from Bank',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Info banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.questionEntity.isNewQuestion
                              ? colorScheme.tertiaryContainer
                              : colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              widget.questionEntity.isNewQuestion
                                  ? LucideIcons.pencil
                                  : LucideIcons.library,
                              size: 16,
                              color: widget.questionEntity.isNewQuestion
                                  ? colorScheme.onTertiaryContainer
                                  : colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.questionEntity.isNewQuestion
                                    ? 'This question was created for this assignment'
                                    : 'This question is from your question bank (read-only)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: widget.questionEntity.isNewQuestion
                                      ? colorScheme.onTertiaryContainer
                                      : colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Question Preview
                      QuestionContentCard(question: question),

                      // Note about editing
                      if (!widget.questionEntity.isNewQuestion) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.info,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'To edit the question content, go to the question bank',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom Action Bar
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                offset: const Offset(0, -4),
                blurRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final shouldPop = await _onWillPop();
                      if (shouldPop && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _hasUnsavedChanges ? _handleSave : null,
                    icon: const Icon(LucideIcons.check, size: 20),
                    label: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
