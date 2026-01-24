import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Minimal Metadata Footer - Displays technical details at the bottom
class QuestionMetadataSection extends StatelessWidget {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? ownerId;
  final String? chapter;

  const QuestionMetadataSection({
    super.key,
    required this.createdAt,
    required this.updatedAt,
    this.ownerId,
    this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('MMM dd, yyyy — hh:mm a');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Other Information',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          DefaultTextStyle(
            style: theme.textTheme.bodySmall!.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (chapter != null && chapter!.isNotEmpty)
                  Text('Chapter: $chapter'),
                Text('Created: ${dateFormat.format(createdAt)}'),
                Text('Last Updated: ${dateFormat.format(updatedAt)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
