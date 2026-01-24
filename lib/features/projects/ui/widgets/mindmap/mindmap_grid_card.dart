import 'package:datn_mobile/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:datn_mobile/features/projects/ui/widgets/common/resource_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MindmapGridCard extends ConsumerWidget {
  final MindmapMinimal mindmap;
  final VoidCallback? onTap;
  final VoidCallback? onMoreOptions;

  const MindmapGridCard({
    super.key,
    required this.mindmap,
    this.onTap,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResourceGridCard(
      title: mindmap.title,
      description: mindmap.description,
      thumbnail: mindmap.thumbnail,
      updatedAt: mindmap.updatedAt,
      resourceType: ResourceType.mindmap,
      onTap: onTap,
      onMoreOptions: onMoreOptions,
    );
  }
}
