import 'package:datn_mobile/features/projects/domain/entity/presentation_minimal.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:datn_mobile/features/projects/ui/widgets/common/abstract_resource_tile.dart';
import 'package:datn_mobile/features/projects/ui/widgets/presentation/presentation_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PresentationTile extends ConsumerWidget {
  final PresentationMinimal presentation;
  final VoidCallback? onTap;
  final VoidCallback? onMoreOptions;

  const PresentationTile({
    super.key,
    required this.presentation,
    this.onTap,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint(
      'PresentationTile: Building with presentation=${presentation.id}, Presentation thumbnail=${presentation.thumbnail != null}',
    );
    return AbstractResourceTile(
      title: presentation.title,
      updatedAt: presentation.updatedAt,
      resourceType: ResourceType.presentation,
      onTap: onTap,
      onMoreOptions: onMoreOptions,
      thumbnail: presentation.thumbnail,
      thumbnailWidget: PresentationThumbnail(
        slide: presentation.thumbnail,
        width: 100,
        height: 100 * 9 / 16,
        showLoadingIndicator: true,
      ),
    );
  }
}
