import 'package:AIPrimary/features/projects/domain/entity/image_project_minimal.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/abstract_resource_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageTile extends ConsumerWidget {
  final ImageProjectMinimal image;
  final VoidCallback? onTap;
  final VoidCallback? onMoreOptions;

  const ImageTile({
    super.key,
    required this.image,
    this.onTap,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("[DEBUG] IMAGE URL: ${image.url.toString()}");
    return AbstractResourceTile(
      title: image.title,
      updatedAt: image.updatedAt,
      resourceType: ResourceType.image,
      onTap: onTap,
      onMoreOptions: onMoreOptions,
      thumbnail: image.url, // Will use imageUrl instead in future
    );
  }
}
