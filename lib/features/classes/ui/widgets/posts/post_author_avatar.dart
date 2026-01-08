import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Avatar widget for post author
class PostAuthorAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String authorName;

  const PostAuthorAvatar({super.key, this.avatarUrl, required this.authorName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: 20,
      backgroundColor: colorScheme.primaryContainer,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Icon(
              LucideIcons.user,
              size: 20,
              color: colorScheme.onPrimaryContainer,
            )
          : null,
    );
  }
}
