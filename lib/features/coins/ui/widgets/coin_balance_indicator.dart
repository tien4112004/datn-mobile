import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/features/coins/providers/coins_providers.dart';
import 'package:shimmer/shimmer.dart';

/// Compact coin balance indicator for displaying user's available coins.
/// Used in generate pages (presentation, mindmap, image) to show balance before generation.
class CoinBalanceIndicator extends ConsumerWidget {
  final VoidCallback? onTap;

  const CoinBalanceIndicator({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coinBalanceAsync = ref.watch(userCoinBalanceProvider);

    return coinBalanceAsync.when(
      data: (coinData) =>
          _buildBalanceChip(context, coinData.coin, onTap: onTap),
      loading: () => _buildLoadingChip(context),
      error: (_, _) => _buildErrorChip(context, onTap: onTap),
    );
  }

  Widget _buildBalanceChip(
    BuildContext context,
    int balance, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.amber.shade50,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.coins, size: 16, color: Colors.amber.shade700),
              const SizedBox(width: 6),
              Text(
                _formatBalance(balance),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.coins, size: 16, color: Colors.amber.shade700),
          const SizedBox(width: 6),
          SizedBox(
            width: 40,
            height: 13,
            child: Shimmer.fromColors(
              baseColor: Colors.amber.shade200,
              highlightColor: Colors.amber.shade100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorChip(BuildContext context, {VoidCallback? onTap}) {
    return Material(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.coins, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                '--',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatBalance(int balance) {
    if (balance >= 1000000) {
      return '${(balance / 1000000).toStringAsFixed(1)}M';
    } else if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(1)}K';
    }
    return NumberFormat('#,###').format(balance);
  }
}
