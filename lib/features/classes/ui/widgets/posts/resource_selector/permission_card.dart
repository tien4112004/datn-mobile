import 'package:datn_mobile/features/classes/domain/entity/permission_level.dart';
import 'package:datn_mobile/features/classes/states/resrouce_selection_state.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PermissionCard extends StatelessWidget {
  final LinkedResourceSelection resource;
  final void Function(String id, PermissionLevel permission) onUpdatePermission;
  final void Function(String id) onRemove;

  const PermissionCard({
    super.key,
    required this.resource,
    required this.onUpdatePermission,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCommentAllowed =
        resource.permissionLevel == PermissionLevel.comment;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Resource Icon
          Icon(
            resource.type == 'presentation'
                ? LucideIcons.presentation
                : LucideIcons.brainCircuit,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Text(
              resource.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),

          // Divider
          Container(height: 24, width: 1, color: colorScheme.outlineVariant),
          const SizedBox(width: 8),

          // Toggle Comment
          Text(
            'Allow Comment',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: isCommentAllowed,
            onChanged: (value) {
              onUpdatePermission(
                resource.id,
                value ? PermissionLevel.comment : PermissionLevel.view,
              );
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),

          const SizedBox(width: 4),

          // Remove Button
          IconButton(
            onPressed: () => onRemove(resource.id),
            icon: const Icon(LucideIcons.x, size: 18),
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: colorScheme.error,
            ),
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}
