import 'package:datn_mobile/features/assignments/ui/widgets/detail/assessment_matrix_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:datn_mobile/shared/models/cms_enums.dart';

/// Matrix tab with clean design matching the Matrix tab reference.
/// Features: Icon badge header, matrix table, colorful summary stats.
class MatrixTab extends StatelessWidget {
  final AssessmentMatrix matrix;
  final bool isEditMode;

  const MatrixTab({super.key, required this.matrix, this.isEditMode = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
                  // Icon badge with light blue background
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEEBFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.grid3x3,
                      color: Color(0xFF0052CC),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assessment Matrix',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${stats.totalActual} ${stats.totalActual == 1 ? 'question' : 'questions'} distributed',
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
              child: _buildMatrixTable(context, theme, colorScheme),
            ),

            const SizedBox(height: 24),

            // Summary Statistics with colorful cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.chartLine, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Summary Statistics',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 2x2 Grid of colorful stat cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          icon: LucideIcons.target,
                          label: 'TARGET',
                          value: '${stats.totalTarget}',
                          backgroundColor: const Color(0xFFDEEBFF),
                          valueColor: const Color(0xFF0052CC),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          icon: LucideIcons.check,
                          label: 'ACTUAL',
                          value: '${stats.totalActual}',
                          backgroundColor: const Color(0xFFFFF4E5),
                          valueColor: const Color(0xFFFF8B00),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          icon: LucideIcons.percent,
                          label: 'COMPLETE',
                          value:
                              '${stats.completionPercentage.toStringAsFixed(0)}%',
                          backgroundColor: const Color(0xFFFFEBEE),
                          valueColor: const Color(0xFFC62828),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          icon: LucideIcons.circleCheck,
                          label: 'MATCHED',
                          value: '${stats.matchedCells}/${stats.totalCells}',
                          backgroundColor: const Color(0xFFE8F5E9),
                          valueColor: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
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
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header Row
          _buildHeaderRow(theme, colorScheme),
          Divider(height: 1, color: colorScheme.outlineVariant),
          // Data Rows
          ...QuestionType.values.map((type) {
            return Column(
              children: [
                _buildDataRow(type, theme, colorScheme),
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

  Widget _buildHeaderRow(ThemeData theme, ColorScheme colorScheme) {
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
              'TYPE',
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
                    Difficulty.advancedApplication,
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
                              _getDifficultyAbbreviation(difficulty),
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
                'TOTAL',
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
                    _getTypeAbbreviation(type),
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
                    Difficulty.advancedApplication,
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

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color backgroundColor,
    required Color valueColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: valueColor),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: valueColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyAbbreviation(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.knowledge:
        return 'KNO';
      case Difficulty.comprehension:
        return 'COM';
      case Difficulty.application:
        return 'APP';
      case Difficulty.advancedApplication:
        return 'ADV';
      default:
        return difficulty.displayName;
    }
  }

  String _getTypeAbbreviation(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'MC';
      case QuestionType.matching:
        return 'Match';
      case QuestionType.openEnded:
        return 'Open';
      case QuestionType.fillInBlank:
        return 'Fill';
    }
  }
}
