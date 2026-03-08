import 'package:AIPrimary/features/notification/domain/entity/app_notification.dart';
import 'package:AIPrimary/features/notification/domain/entity/notification_type.dart';
import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Parses a single markdown line into a list of [TextSpan]s,
/// handling **bold** and *italic* inline markers.
List<TextSpan> _parseInline(String text, TextStyle base) {
  final spans = <TextSpan>[];
  final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|_(.+?)_');
  int last = 0;
  for (final m in pattern.allMatches(text)) {
    if (m.start > last) {
      spans.add(TextSpan(text: text.substring(last, m.start), style: base));
    }
    if (m.group(1) != null) {
      spans.add(
        TextSpan(
          text: m.group(1),
          style: base.copyWith(fontWeight: FontWeight.w600),
        ),
      );
    } else {
      spans.add(
        TextSpan(
          text: m.group(2) ?? m.group(3),
          style: base.copyWith(fontStyle: FontStyle.italic),
        ),
      );
    }
    last = m.end;
  }
  if (last < text.length) {
    spans.add(TextSpan(text: text.substring(last), style: base));
  }
  return spans.isEmpty ? [TextSpan(text: text, style: base)] : spans;
}

class NotificationItem extends ConsumerWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const NotificationItem({super.key, required this.notification, this.onTap});

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.post:
        return Icons.article_outlined;
      case NotificationType.assignment:
        return Icons.assignment_outlined;
      case NotificationType.assignmentDeadline:
        return Icons.alarm_outlined;
      case NotificationType.comment:
        return Icons.comment_outlined;
      case NotificationType.grade:
        return Icons.grade_outlined;
      case NotificationType.announcement:
        return Icons.campaign_outlined;
      case NotificationType.reminder:
        return Icons.alarm_outlined;
      case NotificationType.system:
        return Icons.settings_outlined;
      case NotificationType.sharedPresentation:
        return Icons.slideshow_outlined;
      case NotificationType.sharedMindmap:
        return Icons.account_tree_outlined;
    }
  }

  Color _getIconColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (notification.type) {
      case NotificationType.post:
        return colorScheme.primary;
      case NotificationType.assignment:
        return Colors.orange;
      case NotificationType.assignmentDeadline:
        return Colors.deepOrange;
      case NotificationType.comment:
        return Colors.green;
      case NotificationType.grade:
        return Colors.purple;
      case NotificationType.announcement:
        return Colors.red;
      case NotificationType.reminder:
        return Colors.amber;
      case NotificationType.system:
        return colorScheme.onSurfaceVariant;
      case NotificationType.sharedPresentation:
        return Colors.indigo;
      case NotificationType.sharedMindmap:
        return Colors.teal;
    }
  }

  Widget _buildMarkdownBody(BuildContext context, String body) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.onSurfaceVariant;
    final lines = body.split('\n');
    final widgets = <Widget>[];

    for (final raw in lines) {
      final line = raw.trimRight();
      if (line.isEmpty) continue;

      TextStyle style;
      String content;

      if (line.startsWith('### ')) {
        content = line.substring(4);
        style = TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: baseColor,
        );
      } else if (line.startsWith('## ')) {
        content = line.substring(3);
        style = TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: baseColor,
        );
      } else if (line.startsWith('# ')) {
        content = line.substring(2);
        style = TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: baseColor,
        );
      } else {
        content = line;
        style = TextStyle(fontSize: 12, color: baseColor);
      }

      widgets.add(
        RichText(
          text: TextSpan(children: _parseInline(content, style)),
          maxLines: null,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = _getIconColor(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: notification.isRead
            ? null
            : colorScheme.primaryContainer.withValues(alpha: 0.3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIcon(), size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (notification.body != null) ...[
                    const SizedBox(height: 4),
                    _buildMarkdownBody(context, notification.body!),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    DateFormatHelper.formatRelativeDate(
                      notification.createdAt,
                      ref: ref,
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
