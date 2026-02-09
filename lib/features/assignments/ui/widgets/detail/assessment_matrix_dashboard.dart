import 'package:AIPrimary/features/assignments/domain/entity/api_matrix_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/utils/matrix_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Assessment Matrix Dashboard widget.
///
/// Displays a comprehensive matrix comparing target difficulty/type distribution
/// with actual question distribution. Uses heat map color coding to show alignment.
///
/// Features:
/// - Matrix table with question types × difficulty levels
/// - Target vs Actual comparison with color coding
/// - Summary statistics
/// - Collapsible ExpansionTile
/// - Material 3 design
class AssessmentMatrixDashboard extends ConsumerWidget {
  final AssessmentMatrix matrix;
  final bool initiallyExpanded;

  const AssessmentMatrixDashboard({
    super.key,
    required this.matrix,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Theme(
        data: theme.copyWith(
          dividerColor: Colors.transparent,
          splashColor: colorScheme.primary.withValues(alpha: 0.5),
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              LucideIcons.grid3x3,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          title: Text(
            t.assignments.matrixDashboard.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _buildSubtitle(t),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          children: [
            _buildMatrixTable(context, theme, colorScheme, t),
            const SizedBox(height: 16),
            _buildSummaryStats(context, theme, colorScheme, t),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle(dynamic t) {
    final totalTarget = matrix.getTotalTarget();
    final totalActual = matrix.getTotalActual();
    final matchPercentage = totalTarget > 0
        ? ((totalActual / totalTarget) * 100).toStringAsFixed(0)
        : '0';

    return t.assignments.matrixDashboard.subtitle(
      actual: totalActual,
      target: totalTarget,
      percentage: matchPercentage,
    );
  }

  Widget _buildMatrixTable(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic t,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Header Row
          _buildHeaderRow(theme, colorScheme, t),

          // Divider
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),

          // Data Rows
          ...QuestionType.values.map((type) {
            return Column(
              children: [
                _buildDataRow(type, theme, colorScheme, t),
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

  Widget _buildHeaderRow(ThemeData theme, ColorScheme colorScheme, dynamic t) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          // Type Column Header
          SizedBox(
            width: 100,
            child: Text(
              t.assignments.matrixDashboard.type,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          // Difficulty Column Headers
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

          // Total Column Header
          SizedBox(
            width: 60,
            child: Center(
              child: Text(
                t.assignments.matrixDashboard.total,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(
    QuestionType type,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic t,
  ) {
    final typeColor = QuestionType.getColor(type);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Type Label
          SizedBox(
            width: 100,
            child: Row(
              children: [
                Icon(QuestionType.getIcon(type), size: 16, color: typeColor),
                const SizedBox(width: 8),
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

          // Difficulty Cells
          Expanded(
            child: Row(
              children:
                  [
                    Difficulty.knowledge,
                    Difficulty.comprehension,
                    Difficulty.application,
                  ].map((difficulty) {
                    final target = matrix.getTarget(type, difficulty);
                    final actual = matrix.getActual(type, difficulty);

                    return Expanded(
                      child: Center(
                        child: _buildMatrixCell(
                          target: target,
                          actual: actual,
                          theme: theme,
                          colorScheme: colorScheme,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          // Total Cell
          SizedBox(
            width: 60,
            child: Center(
              child: _buildTotalCell(
                type: type,
                theme: theme,
                colorScheme: colorScheme,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixCell({
    required int target,
    required int actual,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    Color backgroundColor;
    Color textColor;

    if (target == 0 && actual == 0) {
      // Empty cell
      backgroundColor = colorScheme.surfaceContainerHigh.withValues(alpha: 0.3);
      textColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    } else if (actual == target) {
      // Perfect match
      backgroundColor = Colors.green.withValues(alpha: 0.2);
      textColor = Colors.green.shade700;
    } else if (actual > target) {
      // Over target
      backgroundColor = Colors.orange.withValues(alpha: 0.2);
      textColor = Colors.orange.shade700;
    } else if (actual < target) {
      // Under target
      backgroundColor = Colors.red.withValues(alpha: 0.2);
      textColor = Colors.red.shade700;
    } else {
      backgroundColor = colorScheme.surfaceContainerHigh;
      textColor = colorScheme.onSurface;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$actual',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          if (target > 0) ...[
            Text(
              '/$target',
              style: theme.textTheme.labelSmall?.copyWith(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalCell({
    required QuestionType type,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    final targetTotal = matrix.getTypeTargetTotal(type);
    final actualTotal = matrix.getTypeActualTotal(type);

    Color backgroundColor;
    Color textColor;

    if (actualTotal == targetTotal && targetTotal > 0) {
      backgroundColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
    } else {
      backgroundColor = colorScheme.surfaceContainerHigh;
      textColor = colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$actualTotal',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          if (targetTotal > 0) ...[
            Text(
              '/$targetTotal',
              style: theme.textTheme.labelSmall?.copyWith(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryStats(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic t,
  ) {
    final stats = matrix.getStats();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.trendingUp,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                t.assignments.matrixDashboard.summaryStatistics,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatBadge(
                icon: LucideIcons.target,
                label: t.assignments.matrixDashboard.target,
                value: '${stats.totalTarget}',
                color: colorScheme.primary,
                theme: theme,
              ),
              _buildStatBadge(
                icon: LucideIcons.check,
                label: t.assignments.matrixDashboard.actual,
                value: '${stats.totalActual}',
                color: stats.totalActual == stats.totalTarget
                    ? Colors.green
                    : Colors.orange,
                theme: theme,
              ),
              _buildStatBadge(
                icon: LucideIcons.percent,
                label: t.assignments.matrixDashboard.complete,
                value: '${stats.completionPercentage.toStringAsFixed(0)}%',
                color: _getCompletionColor(stats.completionPercentage),
                theme: theme,
              ),
              _buildStatBadge(
                icon: LucideIcons.alignCenterHorizontal,
                label: t.assignments.matrixDashboard.matched,
                value: '${stats.matchedCells}/${stats.totalCells}',
                color: colorScheme.secondary,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color.withValues(alpha: 0.8),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCompletionColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.orange;
    return Colors.red;
  }

  String _getDifficultyAbbreviation(Difficulty difficulty, dynamic t) {
    switch (difficulty) {
      case Difficulty.knowledge:
        return t.assignments.matrix.know;
      case Difficulty.comprehension:
        return t.assignments.matrix.comp;
      case Difficulty.application:
        return t.assignments.matrix.app;
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

/// Assessment matrix data model.
///
/// Supports two modes:
/// - **Topic-based** (from API matrix): target counts per subtopic × difficulty × questionType
/// - **Flat** (computed from questions): actual counts per type × difficulty
class AssessmentMatrix {
  final Map<String, int> _targetMatrix;
  final Map<String, int> _actualMatrix;

  /// Per-subtopic actual counts: "subtopicId:difficultyApi:questionTypeApi" → count
  final Map<String, int> _subtopicActualMatrix;
  final ApiMatrixEntity? apiMatrix;

  AssessmentMatrix({
    required Map<String, int> targetMatrix,
    required Map<String, int> actualMatrix,
    Map<String, int>? subtopicActualMatrix,
    this.apiMatrix,
  }) : _targetMatrix = targetMatrix,
       _actualMatrix = actualMatrix,
       _subtopicActualMatrix = subtopicActualMatrix ?? {};

  factory AssessmentMatrix.empty() {
    return AssessmentMatrix(targetMatrix: {}, actualMatrix: {});
  }

  /// Whether this matrix has topic-based data from the API.
  bool get hasTopicMatrix => apiMatrix != null;

  String _getKey(QuestionType type, Difficulty difficulty) {
    return '${type.name}_${difficulty.name}';
  }

  int getTarget(QuestionType type, Difficulty difficulty) {
    return _targetMatrix[_getKey(type, difficulty)] ?? 0;
  }

  int getActual(QuestionType type, Difficulty difficulty) {
    return _actualMatrix[_getKey(type, difficulty)] ?? 0;
  }

  int getTypeTargetTotal(QuestionType type) {
    return [
      Difficulty.knowledge,
      Difficulty.comprehension,
      Difficulty.application,
    ].fold(0, (sum, diff) => sum + getTarget(type, diff));
  }

  int getTypeActualTotal(QuestionType type) {
    return [
      Difficulty.knowledge,
      Difficulty.comprehension,
      Difficulty.application,
    ].fold(0, (sum, diff) => sum + getActual(type, diff));
  }

  int getTotalTarget() {
    if (apiMatrix != null) return apiMatrix!.totalQuestions;
    return _targetMatrix.values.fold(0, (sum, val) => sum + val);
  }

  int getTotalActual() {
    return _actualMatrix.values.fold(0, (sum, val) => sum + val);
  }

  /// Get target count for a specific subtopic × difficulty from the API matrix.
  /// Sums across all question types for that cell.
  int getSubtopicTarget(int subtopicIndex, int difficultyIndex) {
    if (apiMatrix == null) return 0;
    final row = apiMatrix!.matrix;
    if (subtopicIndex >= row.length) return 0;
    if (difficultyIndex >= row[subtopicIndex].length) return 0;

    int total = 0;
    for (final cellValue in row[subtopicIndex][difficultyIndex]) {
      total += parseCellValue(cellValue).count;
    }
    return total;
  }

  /// Get total target count for a specific subtopic (sum across all difficulties).
  int getSubtopicTotalTarget(int subtopicIndex) {
    if (apiMatrix == null) return 0;
    final row = apiMatrix!.matrix;
    if (subtopicIndex >= row.length) return 0;

    int total = 0;
    for (int d = 0; d < row[subtopicIndex].length; d++) {
      for (final cellValue in row[subtopicIndex][d]) {
        total += parseCellValue(cellValue).count;
      }
    }
    return total;
  }

  /// Get actual count for a specific sub-cell (subtopic × difficulty × questionType).
  int getSubtopicCellActual(
    int subtopicIndex,
    int difficultyIndex,
    int questionTypeIndex,
  ) {
    if (apiMatrix == null) return 0;
    final dims = apiMatrix!.dimensions;
    final subtopics = dims.flatSubtopics;
    if (subtopicIndex >= subtopics.length) return 0;
    if (difficultyIndex >= dims.difficulties.length) return 0;
    if (questionTypeIndex >= dims.questionTypes.length) return 0;

    final key =
        '${subtopics[subtopicIndex].id}:${dims.difficulties[difficultyIndex]}:${dims.questionTypes[questionTypeIndex]}';
    return _subtopicActualMatrix[key] ?? 0;
  }

  /// Get actual count for a subtopic × difficulty (sum across question types).
  int getSubtopicDiffActual(int subtopicIndex, int difficultyIndex) {
    if (apiMatrix == null) return 0;
    final dims = apiMatrix!.dimensions;
    int total = 0;
    for (int q = 0; q < dims.questionTypes.length; q++) {
      total += getSubtopicCellActual(subtopicIndex, difficultyIndex, q);
    }
    return total;
  }

  /// Get actual count for a subtopic (sum across all difficulties and question types).
  int getSubtopicTotalActual(int subtopicIndex) {
    if (apiMatrix == null) return 0;
    final dims = apiMatrix!.dimensions;
    int total = 0;
    for (int d = 0; d < dims.difficulties.length; d++) {
      total += getSubtopicDiffActual(subtopicIndex, d);
    }
    return total;
  }

  MatrixStats getStats() {
    final totalTarget = getTotalTarget();
    final totalActual = getTotalActual();
    final totalCells = QuestionType.values.length * 3; // 3 difficulty levels

    int matchedCells = 0;
    for (final type in QuestionType.values) {
      for (final difficulty in [
        Difficulty.knowledge,
        Difficulty.comprehension,
        Difficulty.application,
      ]) {
        final target = getTarget(type, difficulty);
        final actual = getActual(type, difficulty);
        if (target == actual && target > 0) {
          matchedCells++;
        }
      }
    }

    final completionPercentage = totalTarget > 0
        ? (totalActual / totalTarget) * 100
        : 0.0;

    return MatrixStats(
      totalTarget: totalTarget,
      totalActual: totalActual,
      totalCells: totalCells,
      matchedCells: matchedCells,
      completionPercentage: completionPercentage,
    );
  }
}

/// Matrix statistics model.
class MatrixStats {
  final int totalTarget;
  final int totalActual;
  final int totalCells;
  final int matchedCells;
  final double completionPercentage;

  MatrixStats({
    required this.totalTarget,
    required this.totalActual,
    required this.totalCells,
    required this.matchedCells,
    required this.completionPercentage,
  });
}
