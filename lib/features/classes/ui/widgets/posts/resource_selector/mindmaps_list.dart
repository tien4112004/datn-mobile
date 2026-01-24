import 'package:datn_mobile/features/projects/states/controller_provider.dart';
import 'package:datn_mobile/features/classes/states/selection_state.dart';
import 'package:datn_mobile/features/classes/ui/widgets/posts/resource_selector/resource_tile.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Mindmaps list with loading and empty states
class MindmapsList extends ConsumerWidget {
  final Map<String, LinkedResourceSelection> selectedResources;
  final void Function({
    required String id,
    required String title,
    required String type,
  })
  onToggleSelection;

  const MindmapsList({
    super.key,
    required this.selectedResources,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mindmapsAsync = ref.watch(mindmapsControllerProvider);

    return mindmapsAsync.easyWhen(
      data: (state) {
        final mindmaps = state.value;

        if (mindmaps.isEmpty) {
          return const _EmptyState(
            icon: LucideIcons.brainCircuit,
            message: 'No mindmaps found',
            description: 'Create your first mindmap to organize ideas',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: mindmaps.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final mindmap = mindmaps[index];
            return ResourceTile(
              id: mindmap.id,
              title: mindmap.title,
              type: 'mindmap',
              subtitle: mindmap.updatedAt != null
                  ? 'Updated ${_formatDate(mindmap.updatedAt!)}'
                  : null,
              thumbnail: mindmap.thumbnail,
              icon: LucideIcons.brainCircuit,
              isSelected: selectedResources.containsKey(mindmap.id),
              onToggle: () => onToggleSelection(
                id: mindmap.id,
                title: mindmap.title,
                type: 'mindmap',
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String description;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.description,
  });

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
              child: Icon(icon, size: 48, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
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
