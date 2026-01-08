import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Displays comment author name and timestamp
class CommentAuthorInfo extends StatelessWidget {
  final String authorName;
  final DateTime createdAt;
  final bool isCurrentUser;

  const CommentAuthorInfo({
    super.key,
    required this.authorName,
    required this.createdAt,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Text(
          isCurrentUser ? 'You' : authorName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isCurrentUser ? colorScheme.primary : null,
          ),
        ),
        const SizedBox(width: 8),
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
