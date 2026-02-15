import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/coins/providers/coins_providers.dart';
import 'package:AIPrimary/features/coins/ui/widgets/usage_breakdown_card.dart';
import 'package:AIPrimary/features/coins/data/models/user_coin_model.dart';
import 'package:AIPrimary/features/coins/data/models/token_usage_stats_model.dart';

@RoutePage()
class PaymentMethodsPage extends ConsumerWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coinBalanceAsync = ref.watch(userCoinBalanceProvider);
    final usageByModelAsync = ref.watch(tokenUsageByModelProvider);
    final usageByTypeAsync = ref.watch(tokenUsageByRequestTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Purchase feature coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userCoinBalanceProvider);
          ref.invalidate(tokenUsageByModelProvider);
          ref.invalidate(tokenUsageByRequestTypeProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(context, coinBalanceAsync),
              const SizedBox(height: 24),

              Text(
                'Usage by Model',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildUsageByModelSection(context, usageByModelAsync),
              const SizedBox(height: 24),

              Text(
                'Usage by Type',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildUsageByTypeSection(context, usageByTypeAsync),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    AsyncValue<UserCoinModel> coinBalanceAsync,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.amber.shade400, Colors.amber.shade600],
        ),
        borderRadius: Themes.boxRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Balance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          coinBalanceAsync.when(
            data: (coinData) => Text(
              '${NumberFormat('#,###').format(coinData.coin)} Coins',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            loading: () => const CircularProgressIndicator(color: Colors.white),
            error: (_, _) => Text(
              'Error loading balance',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageByModelSection(
    BuildContext context,
    AsyncValue<List<TokenUsageStatsModel>> usageAsync,
  ) {
    return usageAsync.when(
      data: (usageList) {
        if (usageList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No usage data available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          );
        }
        return Column(
          children: usageList.map((stat) {
            return UsageBreakdownCard(
              title: stat.model ?? 'Unknown Model',
              tokens: stat.totalTokens,
              requests: stat.totalRequests,
              icon: LucideIcons.cpu,
            );
          }).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Error loading data',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildUsageByTypeSection(
    BuildContext context,
    AsyncValue<List<TokenUsageStatsModel>> usageAsync,
  ) {
    return usageAsync.when(
      data: (usageList) {
        if (usageList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No usage data available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          );
        }
        return Column(
          children: usageList.map((stat) {
            return UsageBreakdownCard(
              title: _getRequestTypeLabel(stat.requestType),
              tokens: stat.totalTokens,
              requests: stat.totalRequests,
              icon: _getRequestTypeIcon(stat.requestType),
            );
          }).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Error loading data',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  String _getRequestTypeLabel(String? type) {
    if (type == null) return 'Unknown';
    switch (type.toLowerCase()) {
      case 'text':
        return 'Text Generation';
      case 'image':
        return 'Image Generation';
      case 'mindmap':
        return 'Mind Map Creation';
      case 'presentation':
        return 'Presentation Generation';
      default:
        return type;
    }
  }

  IconData _getRequestTypeIcon(String? type) {
    if (type == null) return LucideIcons.circleQuestionMark;
    switch (type.toLowerCase()) {
      case 'text':
        return LucideIcons.fileText;
      case 'image':
        return LucideIcons.image;
      case 'mindmap':
        return LucideIcons.network;
      case 'presentation':
        return LucideIcons.presentation;
      default:
        return LucideIcons.circleQuestionMark;
    }
  }
}
