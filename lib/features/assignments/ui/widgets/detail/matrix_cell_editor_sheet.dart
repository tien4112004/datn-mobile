import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/utils/matrix_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bottom sheet for editing a single matrix cell's count and points.
///
/// Shown when tapping a sub-cell in the expanded matrix tab (edit mode).
/// Follows the same Material 3 patterns as QuestionPointsAssignmentDialog.
class MatrixCellEditorSheet extends ConsumerStatefulWidget {
  final String topicName;
  final Difficulty difficulty;
  final QuestionType questionType;
  final int initialCount;
  final double initialPoints;
  final void Function(int count, double points) onSave;

  const MatrixCellEditorSheet({
    super.key,
    required this.topicName,
    required this.difficulty,
    required this.questionType,
    required this.initialCount,
    required this.initialPoints,
    required this.onSave,
  });

  @override
  ConsumerState<MatrixCellEditorSheet> createState() =>
      _MatrixCellEditorSheetState();
}

class _MatrixCellEditorSheetState extends ConsumerState<MatrixCellEditorSheet> {
  late TextEditingController _countController;
  late TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    _countController = TextEditingController(text: '${widget.initialCount}');
    _pointsController = TextEditingController(
      text: widget.initialPoints % 1 == 0
          ? '${widget.initialPoints.toInt()}'
          : widget.initialPoints.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _countController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final count = int.tryParse(_countController.text) ?? 0;
    final points = double.tryParse(_pointsController.text) ?? 0.0;
    widget.onSave(count, points);
    Navigator.pop(context);
  }

  void _handleDelete() {
    widget.onSave(0, 0.0);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    final typeColor = QuestionType.getColor(widget.questionType);
    final typeIcon = QuestionType.getIcon(widget.questionType);
    final diffColor = Difficulty.getDifficultyColor(widget.difficulty);
    final diffIcon = Difficulty.getDifficultyIcon(widget.difficulty);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              t.assignments.detail.matrix.editCell,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Context info chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Topic chip
                _buildInfoChip(
                  icon: LucideIcons.tag,
                  label: widget.topicName,
                  color: colorScheme.primary,
                  theme: theme,
                ),
                // Difficulty chip
                _buildInfoChip(
                  icon: diffIcon,
                  label: widget.difficulty.displayName,
                  color: diffColor,
                  theme: theme,
                ),
                // Question type chip
                _buildInfoChip(
                  icon: typeIcon,
                  label: widget.questionType.displayName,
                  color: typeColor,
                  theme: theme,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Count input
            _buildNumberField(
              label: t.assignments.detail.matrix.countLabel,
              controller: _countController,
              allowDecimal: false,
              theme: theme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16),

            // Points input
            _buildNumberField(
              label: t.assignments.detail.matrix.pointsLabel,
              controller: _pointsController,
              allowDecimal: true,
              theme: theme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                // Delete button (only if count > 0)
                if (widget.initialCount > 0)
                  TextButton.icon(
                    onPressed: _handleDelete,
                    icon: Icon(
                      LucideIcons.trash2,
                      size: 16,
                      color: colorScheme.error,
                    ),
                    label: Text(
                      t.assignments.detail.matrix.clearCell,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                const Spacer(),
                // Cancel
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t.assignments.detail.matrix.cancel),
                ),
                const SizedBox(width: 8),
                // Save
                FilledButton(
                  onPressed: _handleSave,
                  child: Text(t.assignments.detail.matrix.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required bool allowDecimal,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        if (allowDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
        else
          FilteringTextInputFormatter.digitsOnly,
        // Clamp max to 128
        _MaxValueFormatter(128),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

/// Formatter that clamps numeric input to a max value.
class _MaxValueFormatter extends TextInputFormatter {
  final int maxValue;

  _MaxValueFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final numValue = double.tryParse(newValue.text);
    if (numValue != null && numValue > maxValue) {
      return oldValue;
    }
    return newValue;
  }
}

/// Shows the matrix cell editor bottom sheet.
Future<void> showMatrixCellEditor({
  required BuildContext context,
  required String topicName,
  required Difficulty difficulty,
  required QuestionType questionType,
  required String cellValue,
  required void Function(int count, double points) onSave,
}) {
  final parsed = parseCellValue(cellValue);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => MatrixCellEditorSheet(
      topicName: topicName,
      difficulty: difficulty,
      questionType: questionType,
      initialCount: parsed.count,
      initialPoints: parsed.points,
      onSave: onSave,
    ),
  );
}
