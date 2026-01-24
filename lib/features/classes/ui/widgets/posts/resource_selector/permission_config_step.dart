import 'package:datn_mobile/features/classes/domain/entity/permission_level.dart';
import 'package:datn_mobile/features/classes/states/selection_state.dart';
import 'package:datn_mobile/features/classes/ui/widgets/posts/resource_selector/permission_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Step 2: Permission configuration
///
/// Allows teachers to set view/comment permissions
/// for each selected resource
class PermissionConfigStep extends StatelessWidget {
  final Map<String, LinkedResourceSelection> selectedResources;
  final void Function(String id, PermissionLevel permission) onUpdatePermission;
  final void Function(String id) onRemoveSelection;

  const PermissionConfigStep({
    super.key,
    required this.selectedResources,
    required this.onUpdatePermission,
    required this.onRemoveSelection,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedResources.isEmpty) {
      return _EmptyPermissionState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Instructions banner
        _InstructionsBanner(),

        const SizedBox(height: 16),

        // Permission cards
        ...selectedResources.values.map(
          (resource) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PermissionCard(
              resource: resource,
              onUpdatePermission: onUpdatePermission,
              onRemove: onRemoveSelection,
            ),
          ),
        ),
      ],
    );
  }
}

class _InstructionsBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.info, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Set permission level for each resource',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPermissionState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.shieldAlert,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No resources selected',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Go back and select resources to configure permissions',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
