import 'package:AIPrimary/features/assignments/domain/entity/api_matrix_entity.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/assessment_matrix_dashboard.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/detail/topic_editor_sheet.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/utils/matrix_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Matrix tab with expandable difficulty columns and cell editing.
///
/// Two display modes:
/// - **Topic-based** (when API matrix is available): rows = topics/subtopics,
///   columns = difficulties (expandable to show question type sub-cells)
/// - **Flat** (fallback): rows = question types, columns = difficulties (read-only)
class MatrixTab extends ConsumerStatefulWidget {
  final AssessmentMatrix matrix;
  final bool isEditMode;

  /// Called when a sub-cell is tapped in edit mode.
  /// Parameters: (topicIndex, difficultyIndex, questionTypeIndex)
  final void Function(int, int, int)? onCellTap;

  /// Called when import template button is tapped in edit mode.
  final VoidCallback? onImportTemplate;

  /// Called when a new topic is added.
  final void Function(String name)? onAddTopic;

  /// Called when a topic is removed by index.
  final void Function(int topicIndex)? onRemoveTopic;

  /// Called when a topic is updated.
  final void Function(int topicIndex, {String? name, bool? hasContext})?
  onUpdateTopic;

  const MatrixTab({
    super.key,
    required this.matrix,
    this.isEditMode = false,
    this.onCellTap,
    this.onImportTemplate,
    this.onAddTopic,
    this.onRemoveTopic,
    this.onUpdateTopic,
  });

  @override
  ConsumerState<MatrixTab> createState() => _MatrixTabState();
}

class _MatrixTabState extends ConsumerState<MatrixTab> {
  /// Which difficulty column is expanded (null = all collapsed).
  int? _expandedDifficultyIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);
    final stats = widget.matrix.getStats();

    return Container(
      color: colorScheme.surfaceContainerLowest,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.assignments.detail.matrix.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.assignments.detail.matrix.distributed(
                            count: stats.totalActual,
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Import button (only show in edit mode)
                  if (widget.isEditMode && widget.onImportTemplate != null)
                    TextButton.icon(
                      onPressed: widget.onImportTemplate,
                      icon: const Icon(LucideIcons.download, size: 18),
                      label: Text(t.assignments.detail.matrix.importButton),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),

            // Matrix table — topic-based or flat
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: widget.matrix.hasTopicMatrix
                  ? _buildTopicMatrixTable(context, theme, colorScheme, t)
                  : _buildFlatMatrixTable(context, theme, colorScheme, t),
            ),

            // Add Topic button (edit mode only, topic-based matrix only)
            if (widget.isEditMode &&
                widget.onAddTopic != null &&
                widget.matrix.hasTopicMatrix)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: OutlinedButton.icon(
                  onPressed: () => _showAddTopicSheet(context),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: Text(t.assignments.detail.matrix.topic.addTopic),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Summary Statistics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.assignments.detail.matrix.summaryStatistics,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: colorScheme.outlineVariant),
                    itemBuilder: (context, index) {
                      final metrics = [
                        (
                          label: t.assignments.detail.matrix.targetCount,
                          value: '${stats.totalTarget}',
                        ),
                        (
                          label: t.assignments.detail.matrix.actualCount,
                          value: '${stats.totalActual}',
                        ),
                        (
                          label: t.assignments.detail.matrix.completion,
                          value:
                              '${stats.completionPercentage.toStringAsFixed(1)}%',
                        ),
                        (
                          label: t.assignments.detail.matrix.matchesFound,
                          value: '${stats.matchedCells} / ${stats.totalCells}',
                        ),
                      ];
                      final metric = metrics[index];
                      return _buildMetricRow(
                        label: metric.label,
                        value: metric.value,
                        theme: theme,
                        colorScheme: colorScheme,
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom padding
            SizedBox(height: widget.isEditMode ? 174.0 : 88.0),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // Topic-based matrix (from API matrix) with expandable difficulty columns
  // ============================================================================

  Widget _buildTopicMatrixTable(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic t,
  ) {
    final apiMatrix = widget.matrix.apiMatrix!;
    final topics = apiMatrix.dimensions.topics;
    final difficulties = apiMatrix.dimensions.difficulties;
    final questionTypes = apiMatrix.dimensions.questionTypes;

    return Column(
      children: [
        // Difficulty toggle chips
        _buildDifficultyToggleRow(difficulties, theme, colorScheme, t),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Header row
              _buildTopicHeaderRow(
                theme,
                colorScheme,
                t,
                difficulties,
                questionTypes,
              ),
              Divider(height: 1, color: colorScheme.outlineVariant),

              // Topics as flat rows (no grouping)
              ...topics.asMap().entries.expand((topicEntry) {
                final topicIndex = topicEntry.key;
                final topic = topicEntry.value;

                return [
                  _buildTopicRow(
                    topic,
                    topicIndex,
                    difficulties,
                    questionTypes,
                    theme,
                    colorScheme,
                  ),
                  if (topicIndex < topics.length - 1)
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                ];
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyToggleRow(
    List<String> difficulties,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic t,
  ) {
    return Row(
      children: difficulties.asMap().entries.map((entry) {
        final diffIndex = entry.key;
        final diffStr = entry.value;
        final difficulty = Difficulty.fromApiValue(diffStr);
        final isSelected = _expandedDifficultyIndex == diffIndex;
        final diffColor = Difficulty.getDifficultyColor(difficulty);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: diffIndex == 0 ? 0 : 4,
              right: diffIndex == difficulties.length - 1 ? 0 : 4,
            ),
            child: Material(
              color: isSelected
                  ? diffColor.withValues(alpha: 0.15)
                  : colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _expandedDifficultyIndex = isSelected ? null : diffIndex;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? diffColor.withValues(alpha: 0.5)
                          : colorScheme.outlineVariant.withValues(alpha: 0.3),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Difficulty.getDifficultyIcon(difficulty),
                        size: 16,
                        color: isSelected
                            ? diffColor
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _getDifficultyAbbreviation(difficulty, t),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? diffColor
                                : colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isSelected
                            ? LucideIcons.chevronUp
                            : LucideIcons.chevronDown,
                        size: 14,
                        color: isSelected
                            ? diffColor
                            : colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopicHeaderRow(
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic t,
    List<String> difficulties,
    List<String> questionTypes,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          // Label column
          SizedBox(
            width: 70,
            child: Text(
              t.assignments.detail.matrix.typeHeader,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Difficulty columns (expandable)
          ...difficulties.asMap().entries.map((entry) {
            final diffIndex = entry.key;
            final diffStr = entry.value;
            final difficulty = Difficulty.fromApiValue(diffStr);
            final isExpanded = _expandedDifficultyIndex == diffIndex;

            return Expanded(
              flex: isExpanded ? 4 : 1,
              child: isExpanded
                  ? _buildExpandedDifficultyHeader(
                      difficulty,
                      questionTypes,
                      theme,
                      colorScheme,
                    )
                  : _buildCollapsedDifficultyHeader(
                      difficulty,
                      theme,
                      colorScheme,
                      t,
                    ),
            );
          }),
          // Total column
          SizedBox(
            width: 50,
            child: Center(
              child: Text(
                t.assignments.detail.matrix.totalHeader,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedDifficultyHeader(
    Difficulty difficulty,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic t,
  ) {
    final isAnyExpanded = _expandedDifficultyIndex != null;
    final diffColor = Difficulty.getDifficultyColor(difficulty);

    return Center(
      child: Column(
        children: [
          Icon(
            Difficulty.getDifficultyIcon(difficulty),
            size: 14,
            color: diffColor,
          ),
          if (!isAnyExpanded) ...[
            const SizedBox(height: 2),
            Text(
              _getDifficultyAbbreviation(difficulty, t),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedDifficultyHeader(
    Difficulty difficulty,
    List<String> questionTypes,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: questionTypes.map((qtStr) {
        final qType = QuestionType.fromApiValue(qtStr);
        return Expanded(
          child: Center(
            child: Icon(
              QuestionType.getIcon(qType),
              size: 14,
              color: QuestionType.getColor(qType),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopicRow(
    MatrixDimensionTopic topic,
    int topicIndex,
    List<String> difficulties,
    List<String> questionTypes,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final totalTarget = widget.matrix.getSubtopicTotalTarget(topicIndex);
    final totalActual = widget.matrix.getSubtopicTotalActual(topicIndex);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topic name and subtopic chips
          Row(
            children: [
              // Topic label (tappable in edit mode)
              GestureDetector(
                onTap: widget.isEditMode && widget.onUpdateTopic != null
                    ? () => _showEditTopicSheet(context, topic, topicIndex)
                    : null,
                child: SizedBox(
                  width: 70,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          topic.name,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            decoration:
                                widget.isEditMode &&
                                    widget.onUpdateTopic != null
                                ? TextDecoration.underline
                                : null,
                            decorationColor: colorScheme.primary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      if (topic.hasContext == true)
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Icon(
                            LucideIcons.bookOpen,
                            size: 12,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      if (widget.isEditMode && widget.onUpdateTopic != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Icon(
                            LucideIcons.pencil,
                            size: 10,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Difficulty cells (collapsed or expanded)
              ...difficulties.asMap().entries.map((entry) {
                final diffIndex = entry.key;
                final isExpanded = _expandedDifficultyIndex == diffIndex;

                if (isExpanded) {
                  return Expanded(
                    flex: 4,
                    child: _buildExpandedDifficultyCell(
                      topicIndex,
                      diffIndex,
                      questionTypes,
                      theme,
                      colorScheme,
                    ),
                  );
                }

                final target = widget.matrix.getSubtopicTarget(
                  topicIndex,
                  diffIndex,
                );
                final actual = widget.matrix.getSubtopicDiffActual(
                  topicIndex,
                  diffIndex,
                );

                return Expanded(
                  flex: 1,
                  child: Center(
                    child: _buildStatusCell(
                      actual: actual,
                      target: target,
                      theme: theme,
                      colorScheme: colorScheme,
                    ),
                  ),
                );
              }),
              // Total
              SizedBox(
                width: 50,
                child: Center(
                  child: _buildStatusCell(
                    actual: totalActual,
                    target: totalTarget,
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                ),
              ),
            ],
          ),
          // Chapter chips (informational)
          if (topic.chapters != null && topic.chapters!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 70),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: topic.chapters!
                    .map(
                      (chapter) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          chapter,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  /// Renders 4 question-type sub-cells for an expanded difficulty column.
  Widget _buildExpandedDifficultyCell(
    int topicIndex,
    int difficultyIndex,
    List<String> questionTypes,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final apiMatrix = widget.matrix.apiMatrix!;

    return Row(
      children: questionTypes.asMap().entries.map((entry) {
        final qTypeIndex = entry.key;
        final cellValue =
            apiMatrix.matrix[topicIndex][difficultyIndex][qTypeIndex];
        final target = parseCellValue(cellValue).count;
        final actual = widget.matrix.getSubtopicCellActual(
          topicIndex,
          difficultyIndex,
          qTypeIndex,
        );
        final isEditable = widget.isEditMode && widget.onCellTap != null;

        return Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isEditable
                ? () =>
                      widget.onCellTap!(topicIndex, difficultyIndex, qTypeIndex)
                : null,
            child: Center(
              child: _buildSubCell(
                actual: actual,
                target: target,
                isEditable: isEditable,
                theme: theme,
                colorScheme: colorScheme,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// A single question-type sub-cell within an expanded difficulty column.
  Widget _buildSubCell({
    required int actual,
    required int target,
    required bool isEditable,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    if (target == 0 && actual == 0 && isEditable) {
      // Empty editable cell — show "+" affordance
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Icon(
            LucideIcons.plus,
            size: 14,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    if (target == 0 && actual == 0) {
      // Empty non-editable cell
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            '-',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    // Cell with value — show actual/target with status color
    final (bgColor, textColor) = _getStatusColors(actual, target, colorScheme);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: isEditable
            ? Border.all(color: textColor.withValues(alpha: 0.4))
            : null,
      ),
      child: Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$actual',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              TextSpan(
                text: '/$target',
                style: TextStyle(color: textColor.withValues(alpha: 0.6)),
              ),
            ],
          ),
          style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ============================================================================
  // Flat matrix (fallback — question type × difficulty, read-only)
  // ============================================================================

  Widget _buildFlatMatrixTable(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic t,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildFlatHeaderRow(theme, colorScheme, t),
          Divider(height: 1, color: colorScheme.outlineVariant),
          ...QuestionType.values.map((type) {
            return Column(
              children: [
                _buildFlatDataRow(type, theme, colorScheme, t),
                if (type != QuestionType.values.last)
                  Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFlatHeaderRow(
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic t,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              t.assignments.detail.matrix.typeHeader,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children:
                  [
                    Difficulty.knowledge,
                    Difficulty.comprehension,
                    Difficulty.application,
                  ].map((difficulty) {
                    return Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Difficulty.getDifficultyIcon(difficulty),
                              size: 16,
                              color: Difficulty.getDifficultyColor(difficulty),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getDifficultyAbbreviation(difficulty, t),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          SizedBox(
            width: 60,
            child: Center(
              child: Text(
                t.assignments.detail.matrix.totalHeader,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlatDataRow(
    QuestionType type,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic t,
  ) {
    final typeColor = QuestionType.getColor(type);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Row(
              children: [
                Icon(QuestionType.getIcon(type), size: 16, color: typeColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _getTypeAbbreviation(type, t),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children:
                  [
                    Difficulty.knowledge,
                    Difficulty.comprehension,
                    Difficulty.application,
                  ].map((difficulty) {
                    final actual = widget.matrix.getActual(type, difficulty);
                    final target = widget.matrix.getTarget(type, difficulty);
                    return Expanded(
                      child: Center(
                        child: _buildStatusCell(
                          actual: actual,
                          target: target,
                          theme: theme,
                          colorScheme: colorScheme,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          SizedBox(
            width: 60,
            child: Center(
              child: _buildStatusCell(
                actual: widget.matrix.getTypeActualTotal(type),
                target: widget.matrix.getTypeTargetTotal(type),
                theme: theme,
                colorScheme: colorScheme,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Shared cell widgets
  // ============================================================================

  /// Status-colored cell showing actual/target in a single line.
  Widget _buildStatusCell({
    required int actual,
    required int target,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    if (target == 0 && actual == 0) {
      return Text(
        '0',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
        textAlign: TextAlign.center,
      );
    }

    final (bgColor, textColor) = _getStatusColors(actual, target, colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$actual',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            TextSpan(
              text: '/$target',
              style: TextStyle(color: textColor.withValues(alpha: 0.6)),
            ),
          ],
        ),
        style: theme.textTheme.labelSmall,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Returns (backgroundColor, textColor) based on fulfillment status.
  (Color, Color) _getStatusColors(
    int actual,
    int target,
    ColorScheme colorScheme,
  ) {
    if (actual == target && target > 0) {
      // Fulfilled
      return (Colors.green.withValues(alpha: 0.15), Colors.green.shade700);
    } else if (actual > target) {
      // Excess
      return (Colors.orange.withValues(alpha: 0.15), Colors.orange.shade700);
    } else {
      // Lack (actual < target)
      return (Colors.red.withValues(alpha: 0.15), Colors.red.shade700);
    }
  }

  Widget _buildMetricRow({
    required String label,
    required String value,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Topic editor sheet helpers
  // ============================================================================

  Future<void> _showAddTopicSheet(BuildContext context) async {
    final result = await showTopicEditorSheet(context: context);
    if (result == null) return;

    if (result.action == TopicEditorAction.save && result.name != null) {
      widget.onAddTopic?.call(result.name!);
    }
  }

  Future<void> _showEditTopicSheet(
    BuildContext context,
    MatrixDimensionTopic topic,
    int topicIndex,
  ) async {
    final apiMatrix = widget.matrix.apiMatrix;
    final topicCount = apiMatrix?.dimensions.topics.length ?? 1;

    final result = await showTopicEditorSheet(
      context: context,
      existingTopic: topic,
      canDelete: topicCount > 1,
    );
    if (result == null) return;

    if (result.action == TopicEditorAction.save) {
      widget.onUpdateTopic?.call(
        topicIndex,
        name: result.name,
        hasContext: result.hasContext,
      );
    } else if (result.action == TopicEditorAction.delete) {
      widget.onRemoveTopic?.call(topicIndex);
    }
  }

  String _getDifficultyAbbreviation(Difficulty difficulty, dynamic t) {
    switch (difficulty) {
      case Difficulty.knowledge:
        return t.assignments.matrix.kno;
      case Difficulty.comprehension:
        return t.assignments.matrix.com;
      case Difficulty.application:
        return t.assignments.matrix.appAbbr;
      case Difficulty.advancedApplication:
        return 'Adv';
    }
  }

  String _getTypeAbbreviation(QuestionType type, dynamic t) {
    switch (type) {
      case QuestionType.multipleChoice:
        return t.assignments.matrix.mc;
      case QuestionType.matching:
        return t.assignments.matrix.match;
      case QuestionType.openEnded:
        return t.assignments.matrix.open;
      case QuestionType.fillInBlank:
        return t.assignments.matrix.fill;
    }
  }
}
