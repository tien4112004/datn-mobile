import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
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
import 'package:AIPrimary/i18n/strings.g.dart';

@RoutePage()
class PaymentMethodsPage extends ConsumerWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final coinBalanceAsync = ref.watch(userCoinBalanceProvider);
    final usageByModelAsync = ref.watch(tokenUsageByModelProvider);
    final usageByTypeAsync = ref.watch(tokenUsageByRequestTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.payment.paymentMethods.title),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              context.router.push(const CoinPurchaseRoute());
            },
            icon: const Icon(LucideIcons.plus, size: 18),
            label: Text(t.payment.paymentMethods.buyCoin),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 16),
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
              _buildBalanceCard(context, coinBalanceAsync, t),
              const SizedBox(height: 24),

              Text(
                t.payment.paymentMethods.usageByModel,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildUsageByModelSection(context, usageByModelAsync, t),
              const SizedBox(height: 24),

              Text(
                t.payment.paymentMethods.usageByType,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildUsageByTypeSection(context, usageByTypeAsync, t),
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
    Translations t,
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
            t.payment.paymentMethods.currentBalance,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          coinBalanceAsync.easyWhen(
            data: (coinData) => Text(
              '${NumberFormat('#,###').format(coinData.coin)} ${t.payment.paymentMethods.coinsLabel}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageByModelSection(
    BuildContext context,
    AsyncValue<List<TokenUsageStatsModel>> usageAsync,
    Translations t,
  ) {
    return usageAsync.easyWhen(
      data: (usageList) {
        if (usageList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                t.payment.paymentMethods.noUsageData,
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
              coins: stat.totalCoin,
              requests: stat.totalRequests,
              icon: LucideIcons.cpu,
              imagePath: _getProviderImage(stat.model),
            );
          }).toList(),
        );
      },
      errorWidget: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            t.payment.paymentMethods.errorLoadingData,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildUsageByTypeSection(
    BuildContext context,
    AsyncValue<List<TokenUsageStatsModel>> usageAsync,
    Translations t,
  ) {
    return usageAsync.easyWhen(
      data: (usageList) {
        if (usageList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                t.payment.paymentMethods.noUsageData,
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
              title: _getRequestTypeLabel(stat.requestType, t),
              coins: stat.totalCoin,
              requests: stat.totalRequests,
              icon: _getRequestTypeIcon(stat.requestType, t),
            );
          }).toList(),
        );
      },
      errorWidget: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            t.payment.paymentMethods.errorLoadingData,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  String _getRequestTypeLabel(String? type, Translations t) {
    if (type == null) return t.payment.paymentMethods.unknown;
    switch (type.toLowerCase()) {
      case 'outline':
        return t.payment.paymentMethods.outlineGeneration;
      case 'image':
        return t.payment.paymentMethods.imageGeneration;
      case 'mindmap':
        return t.payment.paymentMethods.mindMapCreation;
      case 'presentation':
        return t.payment.paymentMethods.presentationGeneration;
      default:
        return type;
    }
  }

  IconData _getRequestTypeIcon(String? type, Translations t) {
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

  String? _getProviderImage(String? model) {
    if (model == null) return null;
    final modelLower = model.toLowerCase();

    if (modelLower.contains('gpt') || modelLower.contains('openai')) {
      return 'assets/images/providers/openai.png';
    } else if (modelLower.contains('gemini') || modelLower.contains('google')) {
      return 'assets/images/providers/google.png';
    } else if (modelLower.contains('deepseek')) {
      return 'assets/images/providers/deepseek.png';
    } else if (modelLower.contains('localai')) {
      return 'assets/images/providers/localai.png';
    } else if (modelLower.contains('openrouter')) {
      return 'assets/images/providers/openrouter.png';
    }

    return null;
  }
}
