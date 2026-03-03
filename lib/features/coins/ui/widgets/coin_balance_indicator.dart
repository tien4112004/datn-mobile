import 'package:AIPrimary/core/theme/coin_colors.dart';
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
      color: CoinColors.backgroundLight,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.coins, size: 16, color: CoinColors.accent),
              const SizedBox(width: 6),
              Text(
                _formatBalance(balance),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: CoinColors.textDarkest,
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
        color: CoinColors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.coins, size: 16, color: CoinColors.accent),
          const SizedBox(width: 6),
          SizedBox(
            width: 40,
            height: 13,
            child: Shimmer.fromColors(
              baseColor: CoinColors.shimmerBase,
              highlightColor: CoinColors.shimmerHighlight,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
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
              Icon(LucideIcons.coins, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                '--',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.grey.shade600,
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
