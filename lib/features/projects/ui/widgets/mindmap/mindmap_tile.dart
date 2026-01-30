import 'package:AIPrimary/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/abstract_resource_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MindmapTile extends ConsumerWidget {
  final MindmapMinimal mindmap;
  final VoidCallback? onTap;
  final VoidCallback? onMoreOptions;

  const MindmapTile({
    super.key,
    required this.mindmap,
    this.onTap,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AbstractResourceTile(
      title: mindmap.title,
      updatedAt: mindmap.updatedAt,
      resourceType: ResourceType.mindmap,
      onTap: onTap,
      onMoreOptions: onMoreOptions,
      thumbnail: mindmap.thumbnail,
    );
  }
}
