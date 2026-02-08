import 'package:AIPrimary/features/assignments/domain/entity/assignment_question_entity.dart';
import 'package:AIPrimary/features/questions/domain/entity/question_bank_item_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/utils/enum_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Dialog for assigning points to selected questions from the question bank.
///
/// Shows a list of selected questions with input fields for points.
/// Provides a quick "Apply All" action to set the same points for all questions.
class QuestionPointsAssignmentDialog extends ConsumerStatefulWidget {
  final List<QuestionBankItemEntity> selectedQuestions;
  final List<String> contextTitles;

  const QuestionPointsAssignmentDialog({
    super.key,
    required this.selectedQuestions,
    this.contextTitles = const [],
  });

  /// Show the points assignment dialog
  static Future<List<AssignmentQuestionEntity>?> show(
    BuildContext context,
    List<QuestionBankItemEntity> selectedQuestions, {
    List<String> contextTitles = const [],
  }) {
    return showDialog<List<AssignmentQuestionEntity>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuestionPointsAssignmentDialog(
        selectedQuestions: selectedQuestions,
        contextTitles: contextTitles,
      ),
    );
  }

  @override
  ConsumerState<QuestionPointsAssignmentDialog> createState() =>
      _QuestionPointsAssignmentDialogState();
}

class _QuestionPointsAssignmentDialogState
    extends ConsumerState<QuestionPointsAssignmentDialog> {
  late final Map<String, TextEditingController> _pointsControllers;
  late final Map<String, double> _points;
  final _applyAllController = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    _pointsControllers = {};
    _points = {};

    for (final question in widget.selectedQuestions) {
      final controller = TextEditingController(text: '10');
      _pointsControllers[question.id] = controller;
      _points[question.id] = 10.0;

      controller.addListener(() {
        final value = double.tryParse(controller.text) ?? 0.0;
        setState(() {
          _points[question.id] = value;
        });
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _pointsControllers.values) {
      controller.dispose();
    }
    _applyAllController.dispose();
    super.dispose();
  }

  double get _totalPoints => _points.values.fold(0.0, (sum, val) => sum + val);

  void _applyAllPoints() {
    final t = ref.read(translationsPod);
    final value = double.tryParse(_applyAllController.text) ?? 10.0;
    if (value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.assignments.pointsAssignment.pointsMustBeGreaterThanZero,
          ),
        ),
      );
      return;
    }

    for (final controller in _pointsControllers.values) {
      controller.text = value.toStringAsFixed(0);
    }
  }

  void _handleAdd() {
    final t = ref.read(translationsPod);
    // Validate all points
    for (final entry in _points.entries) {
      if (entry.value <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.assignments.pointsAssignment.allPointsMustBeGreaterThanZero,
            ),
          ),
        );
        return;
      }
    }

    // Create AssignmentQuestionEntity list
    final assignmentQuestions = widget.selectedQuestions.map((bankItem) {
      return AssignmentQuestionEntity(
        questionBankId: bankItem.id,
        question: bankItem.question,
        points: _points[bankItem.id] ?? 10.0,
        isNewQuestion: true,
        contextId: bankItem.contextId,
      );
    }).toList();

    Navigator.pop(context, assignmentQuestions);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              t.assignments.pointsAssignment.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              t.assignments.pointsAssignment.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Apply All section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _applyAllController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: t.assignments.pointsAssignment.applyAll,
                      suffixText: t.assignments.pointsAssignment.pts,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _applyAllPoints,
                  icon: const Icon(LucideIcons.copy, size: 18),
                  label: Text(t.assignments.pointsAssignment.apply),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Divider
            Divider(color: colorScheme.outlineVariant),
            const SizedBox(height: 16),

            // Context import banner
            if (widget.contextTitles.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.bookOpen,
                          size: 18,
                          color: colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t.assignments.pointsAssignment.contextBannerTitle(
                              count: widget.contextTitles.length.toString(),
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...widget.contextTitles.map(
                      (title) => Padding(
                        padding: const EdgeInsets.only(left: 28, bottom: 4),
                        child: Text(
                          title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Questions list
            Expanded(
              child: ListView.separated(
                itemCount: widget.selectedQuestions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final bankItem = widget.selectedQuestions[index];
                  final question = bankItem.question;

                  return _QuestionPointItem(
                    index: index + 1,
                    title: question.title,
                    type: question.type,
                    controller: _pointsControllers[bankItem.id]!,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Total points
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.assignments.pointsAssignment.totalPoints,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    t.assignments.pointsAssignment.pointsValue(
                      points: _totalPoints.toStringAsFixed(0),
                    ),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t.assignments.pointsAssignment.cancel),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _handleAdd,
                  child: Text(t.assignments.pointsAssignment.addQuestions),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for a single question point input item
class _QuestionPointItem extends ConsumerWidget {
  final int index;
  final String title;
  final QuestionType type;
  final TextEditingController controller;

  const _QuestionPointItem({
    required this.index,
    required this.title,
    required this.type,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Question number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Question info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      QuestionType.getIcon(type),
                      size: 14,
                      color: QuestionType.getColor(type),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      type.localizedName(t),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Points input
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                suffixText: t.assignments.pointsAssignment.pts,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
