import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Options menu for post actions (pin, edit, delete)
class PostOptionsMenu extends ConsumerWidget {
  final bool isPinned;
  final VoidCallback onTogglePin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PostOptionsMenu({
    super.key,
    required this.isPinned,
    required this.onTogglePin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    return Semantics(
      label: t.classes.postOptions.label,
      button: true,
      child: PopupMenuButton<String>(
        icon: const Icon(LucideIcons.ellipsisVertical, size: 20),
        onSelected: (value) {
          HapticFeedback.selectionClick();
          switch (value) {
            case 'pin':
              onTogglePin();
              break;
            case 'edit':
              onEdit();
              break;
            case 'delete':
              onDelete();
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'pin',
            child: Row(
              children: [
                Icon(isPinned ? LucideIcons.pinOff : LucideIcons.pin, size: 18),
                const SizedBox(width: 12),
                Text(
                  isPinned
                      ? t.classes.postOptions.unpin
                      : t.classes.postOptions.pin,
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                const Icon(LucideIcons.pencil, size: 18),
                const SizedBox(width: 12),
                Text(t.classes.postOptions.edit),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(LucideIcons.trash2, size: 18),
                const SizedBox(width: 12),
                Text(t.classes.postOptions.delete),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
