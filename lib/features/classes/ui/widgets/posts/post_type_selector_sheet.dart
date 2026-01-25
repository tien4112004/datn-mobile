import 'package:datn_mobile/features/classes/domain/entity/post_type.dart';
import 'package:datn_mobile/features/classes/ui/extensions/post_type_extension.dart';
import 'package:datn_mobile/features/classes/ui/widgets/posts/post_type_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PostTypeSelectorSheet extends StatelessWidget {
  final PostType selectedType;
  final ValueChanged<PostType> onTypeSelected;

  const PostTypeSelectorSheet({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              children: [
                Icon(
                  LucideIcons.layoutList,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  'Post Type',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Post type options
          PostTypeOption(
            icon: PostType.general.icon,
            label: PostType.general.createPageLabel,
            description: 'Share updates with attachments and resources',
            isSelected: selectedType == PostType.general,
            onTap: () {
              onTypeSelected(PostType.general);
              Navigator.pop(context);
              HapticFeedback.selectionClick();
            },
          ),
          PostTypeOption(
            icon: PostType.exercise.icon,
            label: PostType.exercise.createPageLabel,
            description: 'Link assignments for students',
            isSelected: selectedType == PostType.exercise,
            onTap: () {
              onTypeSelected(PostType.exercise);
              Navigator.pop(context);
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ),
    );
  }
}
