import 'package:AIPrimary/shared/widgets/skeleton_card.dart' show SkeletonCard;
import 'package:flutter/material.dart';

class PresentationSkeletonLoadingState extends StatelessWidget {
  final bool gridLoading;
  final int itemCount;
  final int badgeCount;

  const PresentationSkeletonLoadingState({
    super.key,
    this.gridLoading = false,
    this.itemCount = 5,
    this.badgeCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (gridLoading) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) =>
            SkeletonCard(badgeCount: badgeCount, showSubtitle: true),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) =>
            SkeletonCard(badgeCount: badgeCount, showSubtitle: true),
      );
    }
  }
}
