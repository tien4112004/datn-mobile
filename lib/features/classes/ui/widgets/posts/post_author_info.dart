import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Displays post author name and timestamp
class PostAuthorInfo extends StatelessWidget {
  final String authorName;
  final DateTime createdAt;

  const PostAuthorInfo({
    super.key,
    required this.authorName,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          authorName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          timeago.format(createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
