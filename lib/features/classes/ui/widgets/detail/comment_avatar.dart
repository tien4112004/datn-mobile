import 'package:flutter/material.dart';

/// Avatar widget for comment author
class CommentAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String authorName;

  const CommentAvatar({super.key, this.avatarUrl, required this.authorName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = avatarUrl != null;

    return CircleAvatar(
      radius: 16,
      backgroundImage: hasImage ? NetworkImage(avatarUrl!) : null,
      backgroundColor: hasImage ? Colors.grey[200] : colorScheme.primary,
      child: !hasImage
          ? Text(
              _getInitials(authorName),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts[0] : '';
    final lastName = parts.length > 1 ? parts[parts.length - 1] : '';

    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }
}
