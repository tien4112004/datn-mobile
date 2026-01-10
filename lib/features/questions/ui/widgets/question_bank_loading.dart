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
      itemBuilder: (context, index) => _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badges skeleton
            Row(
              children: [
                _ShimmerBox(
                  width: 100,
                  height: 24,
                  borderRadius: 6,
                  color: colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(width: 8),
                _ShimmerBox(
                  width: 80,
                  height: 24,
                  borderRadius: 6,
                  color: colorScheme.surfaceContainerHighest,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title skeleton
            _ShimmerBox(
              width: double.infinity,
              height: 20,
              borderRadius: 4,
              color: colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 8),
            // Subtitle skeleton
            _ShimmerBox(
              width: 200,
              height: 20,
              borderRadius: 4,
              color: colorScheme.surfaceContainerHighest,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color color;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
