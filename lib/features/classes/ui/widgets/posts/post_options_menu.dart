import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Options menu for post actions (pin, edit, delete)
class PostOptionsMenu extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Post options',
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
                Text(isPinned ? 'Unpin' : 'Pin'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(LucideIcons.pencil, size: 18),
                SizedBox(width: 12),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(LucideIcons.trash2, size: 18),
                SizedBox(width: 12),
                Text('Delete'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
