import 'package:datn_mobile/features/projects/domain/entity/image_project_minimal.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:datn_mobile/features/projects/ui/widgets/common/resource_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageGridCard extends ConsumerWidget {
  final ImageProjectMinimal image;
  final VoidCallback? onTap;
  final VoidCallback? onMoreOptions;

  const ImageGridCard({
    super.key,
    required this.image,
    this.onTap,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResourceGridCard(
      title: image.title,
      updatedAt: image.updatedAt,
      resourceType: ResourceType.image,
      onTap: onTap,
      onMoreOptions: onMoreOptions,
      thumbnail: image.url,
    );
  }
}
