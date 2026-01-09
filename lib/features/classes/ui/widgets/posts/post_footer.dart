import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Footer section of a post card with comment count and edited indicator
class PostFooter extends StatelessWidget {
  final bool allowComments;
  final int commentCount;
  final bool showComments;
  final VoidCallback onToggleComments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostFooter({
    super.key,
    required this.allowComments,
    required this.commentCount,
    required this.showComments,
    required this.onToggleComments,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: allowComments
          ? BoxDecoration(
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            )
          : null,
      child: Row(
        children: [
          // Comment count button
          if (allowComments)
            Semantics(
              label: '$commentCount comments',
              button: true,
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onToggleComments();
                },
                icon: Icon(
                  showComments
                      ? LucideIcons.messageSquare
                      : LucideIcons.messageSquare,
                  size: 18,
                ),
                label: Text('$commentCount'),
              ),
            ),

          const Spacer(),
        ],
      ),
    );
  }
}
