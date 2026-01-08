import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Pin indicator icon shown next to author name when post is pinned
class PostPinIndicator extends StatelessWidget {
  final bool isPinned;

  const PostPinIndicator({super.key, required this.isPinned});

  @override
  Widget build(BuildContext context) {
    if (!isPinned) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8),
        Icon(LucideIcons.pin, size: 14, color: colorScheme.primary),
      ],
    );
  }
}
