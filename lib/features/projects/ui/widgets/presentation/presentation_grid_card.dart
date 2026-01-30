import 'package:AIPrimary/features/projects/domain/entity/presentation_minimal.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/resource_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PresentationGridCard extends ConsumerWidget {
  final PresentationMinimal presentation;
  final VoidCallback? onTap;
  final VoidCallback? onMoreOptions;

  const PresentationGridCard({
    super.key,
    required this.presentation,
    this.onTap,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResourceGridCard(
      title: presentation.title,
      updatedAt: presentation.updatedAt,
      thumbnail: presentation.thumbnail,
      resourceType: ResourceType.presentation,
      onTap: onTap,
      onMoreOptions: onMoreOptions,
    );
  }
}
