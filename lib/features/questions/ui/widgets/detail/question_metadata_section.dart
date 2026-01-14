import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

/// Enhanced Metadata Section - Displays question metadata with improved visual hierarchy
///
/// Features:
/// - SurfaceContainerLowest background for subtle appearance
/// - Icons with reduced opacity for better hierarchy
/// - Uppercase labels with letter spacing
/// - Date format: "MMM dd, yyyy — hh:mm a"
/// - Monospace font for owner ID
class QuestionMetadataSection extends StatelessWidget {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? ownerId;
  final String? grade;
  final String? chapter;
  final String? subject;

  const QuestionMetadataSection({
    super.key,
    required this.createdAt,
    required this.updatedAt,
    this.ownerId,
    this.grade,
    this.chapter,
    this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('MMM dd, yyyy — hh:mm a');

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metadata',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            // Created Date
            _buildMetadataRow(
              context: context,
              icon: LucideIcons.calendar,
              label: 'CREATED',
              value: dateFormat.format(createdAt),
            ),
            const SizedBox(height: 16),
            // Updated Date
            _buildMetadataRow(
              context: context,
              icon: LucideIcons.refreshCw,
              label: 'LAST UPDATED',
              value: dateFormat.format(updatedAt),
              valueColor: colorScheme.onSurfaceVariant,
            ),
            // Grade (if available)
            if (grade != null && grade!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildMetadataRow(
                context: context,
                icon: LucideIcons.bookOpen,
                label: 'GRADE',
                value: grade!,
              ),
            ],
            // Subject (if available)
            if (subject != null && subject!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildMetadataRow(
                context: context,
                icon: LucideIcons.library,
                label: 'SUBJECT',
                value: subject!,
              ),
            ],
            // Chapter (if available)
            if (chapter != null && chapter!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildMetadataRow(
                context: context,
                icon: LucideIcons.layers,
                label: 'CHAPTER',
                value: chapter!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
