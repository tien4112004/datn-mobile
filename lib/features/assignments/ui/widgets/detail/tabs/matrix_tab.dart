import 'package:AIPrimary/features/assignments/ui/widgets/detail/assessment_matrix_dashboard.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';

/// Matrix tab with clean design matching the Matrix tab reference.
/// Features: Icon badge header, matrix table, colorful summary stats.
class MatrixTab extends ConsumerWidget {
  final AssessmentMatrix matrix;
  final bool isEditMode;

  const MatrixTab({super.key, required this.matrix, this.isEditMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);
    final stats = matrix.getStats();

    return Container(
      color: colorScheme.surfaceContainerLowest,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clean header with icon badge (like in reference)
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
                ],
              ),
            ),

            // Type & Difficulty Matrix Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildMatrixTable(context, theme, colorScheme, t),
            ),

            const SizedBox(height: 24),

            // Summary Statistics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Removed decorative icon container
                      Text(
                        t.assignments.detail.matrix.summaryStatistics,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    separatorBuilder: (context, index) {
                      return Divider(
                        indent: 0,
                        height: 1,
                        color: colorScheme.outlineVariant,
                      );
                    },
                    itemBuilder: (context, index) {
                      final metrics = [
                        (
                          icon: LucideIcons.target,
                          label: t.assignments.detail.matrix.targetCount,
                          value: '${stats.totalTarget}',
                        ),
                        (
                          icon: LucideIcons.check,
                          label: t.assignments.detail.matrix.actualCount,
                          value: '${stats.totalActual}',
                        ),
                        (
                          icon: LucideIcons.percent,
                          label: t.assignments.detail.matrix.completion,
                          value:
                              '${stats.completionPercentage.toStringAsFixed(1)}%',
                        ),
                        (
                          icon: LucideIcons.circleCheck,
                          label: t.assignments.detail.matrix.matchesFound,
                          value: '${stats.matchedCells} / ${stats.totalCells}',
                        ),
                      ];

                      final metric = metrics[index];
                      return _buildMetricRow(
                        context,
                        icon: metric.icon,
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
            SizedBox(height: isEditMode ? 174.0 : 88.0),
          ],
        ),
      ),
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
      ),
      child: Column(
        children: [
          // Header Row
          _buildHeaderRow(theme, colorScheme, t),
          Divider(height: 1, color: colorScheme.outlineVariant),
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

  Widget _buildDataRow(
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
                    final actual = matrix.getActual(type, difficulty);
                    return Expanded(
                      child: Center(
                        child: _buildMatrixCell(actual, theme, colorScheme),
                      ),
                    );
                  }).toList(),
            ),
          ),
          SizedBox(
            width: 60,
            child: Center(
              child: _buildTotalCell(
                matrix.getTypeActualTotal(type),
                theme,
                colorScheme,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixCell(
    int actual,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    Color backgroundColor;
    Color textColor;

    if (actual == 0) {
      backgroundColor = colorScheme.surfaceContainerHigh.withValues(alpha: 0.5);
      textColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    } else {
      backgroundColor = const Color(0xFFFFF4E5); // Light orange
      textColor = const Color(0xFFFF8B00); // Orange
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$actual',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTotalCell(int total, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$total',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 16),
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

  String _getDifficultyAbbreviation(Difficulty difficulty, dynamic t) {
    switch (difficulty) {
      case Difficulty.knowledge:
        return t.assignments.matrix.kno;
      case Difficulty.comprehension:
        return t.assignments.matrix.com;
      case Difficulty.application:
        return t.assignments.matrix.appAbbr;
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
