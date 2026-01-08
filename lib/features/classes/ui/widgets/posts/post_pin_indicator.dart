import 'package:flutter/material.dart';

/// Pin indicator icon shown next to author name when post is pinned
class PostPinIndicator extends StatelessWidget {
  final bool isPinned;
  final Color color;
  final double size;

  const PostPinIndicator({
    super.key,
    required this.isPinned,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPinned) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8),
        Icon(Icons.push_pin, size: size, color: color, fill: 1),
      ],
    );
  }
}
