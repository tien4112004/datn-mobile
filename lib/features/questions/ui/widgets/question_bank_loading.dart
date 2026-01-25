import 'package:datn_mobile/shared/widgets/skeleton_card.dart';
import 'package:flutter/material.dart';

/// Loading skeleton widget for Question Bank page
class QuestionBankLoading extends StatelessWidget {
  final int itemCount;

  const QuestionBankLoading({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) =>
          const SkeletonCard(badgeCount: 2, showSubtitle: true),
    );
  }
}
