import 'package:AIPrimary/features/projects/domain/entity/presentation_minimal.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/abstract_resource_tile.dart';
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
    return AbstractResourceTile(
      title: presentation.title,
      updatedAt: presentation.updatedAt,
      resourceType: ResourceType.presentation,
      onTap: onTap,
      onMoreOptions: onMoreOptions,
      thumbnail: presentation.thumbnail,
    );
  }
}
