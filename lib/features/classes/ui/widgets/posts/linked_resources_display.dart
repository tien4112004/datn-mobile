import 'package:datn_mobile/features/classes/ui/widgets/posts/linked_resource_card.dart';
import 'package:datn_mobile/features/classes/domain/entity/linked_resource_entity.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Widget to display linked resources in a post
/// Fetches resource details and displays them as interactive cards
class LinkedResourcesDisplay extends StatelessWidget {
  final List<LinkedResourceEntity> linkedResources;

  const LinkedResourcesDisplay({super.key, required this.linkedResources});

  @override
  Widget build(BuildContext context) {
    if (linkedResources.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.link,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '${linkedResources.length} linked resource${linkedResources.length > 1 ? 's' : ''}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: linkedResources
                .map(
                  (resource) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: LinkedResourceCard(resource: resource),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
