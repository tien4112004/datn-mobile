import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

/// Displays question metadata including created and updated timestamps
class QuestionMetadataSection extends StatelessWidget {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? ownerId;

  const QuestionMetadataSection({
    super.key,
    required this.createdAt,
    required this.updatedAt,
    this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Metadata',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Created At
                _buildMetadataRow(
                  context: context,
                  icon: LucideIcons.calendarPlus,
                  label: 'Created',
                  value: dateFormat.format(createdAt),
                ),

                const SizedBox(height: 12),

                // Updated At
                _buildMetadataRow(
                  context: context,
                  icon: LucideIcons.calendarClock,
                  label: 'Last Updated',
                  value: dateFormat.format(updatedAt),
                ),

                // Owner ID (if available)
                if (ownerId != null) ...[
                  const SizedBox(height: 12),
                  _buildMetadataRow(
                    context: context,
                    icon: LucideIcons.user,
                    label: 'Owner ID',
                    value: ownerId!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
