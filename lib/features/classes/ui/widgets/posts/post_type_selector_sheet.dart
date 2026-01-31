import 'package:AIPrimary/features/classes/domain/entity/post_type.dart';
import 'package:AIPrimary/features/classes/ui/extensions/post_type_extension.dart';
import 'package:AIPrimary/features/classes/ui/widgets/posts/post_type_option.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PostTypeSelectorSheet extends ConsumerWidget {
  final PostType selectedType;
  final ValueChanged<PostType> onTypeSelected;

  const PostTypeSelectorSheet({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

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
                  t.classes.postType.title,
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
            icon: PostType.post.icon,
            label: t.classes.postType.post,
            description: t.classes.postType.postDescription,
            isSelected: selectedType == PostType.post,
            onTap: () {
              onTypeSelected(PostType.post);
              Navigator.pop(context);
              HapticFeedback.selectionClick();
            },
          ),
          PostTypeOption(
            icon: PostType.exercise.icon,
            label: t.classes.postType.exercise,
            description: t.classes.postType.exerciseDescription,
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
