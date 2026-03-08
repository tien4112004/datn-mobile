import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

/// Displays comment author name and timestamp
class CommentAuthorInfo extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Row(
      children: [
        Text(
          isCurrentUser ? t.common.you : authorName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isCurrentUser ? colorScheme.primary : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          DateFormatHelper.formatRelativeDate(createdAt, ref: ref),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
