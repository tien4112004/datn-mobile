import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/core/theme/coin_colors.dart';
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
      appBar: AppBar(title: Text(t.payment.paymentMethods.title)),
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

              _buildSectionHeader(
                context,
                icon: LucideIcons.cpu,
                title: t.payment.paymentMethods.usageByModel,
              ),
              const SizedBox(height: 12),
              _buildUsageByModelSection(context, usageByModelAsync, t),
              const SizedBox(height: 24),

              _buildSectionHeader(
                context,
                icon: LucideIcons.layoutGrid,
                title: t.payment.paymentMethods.usageByType,
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

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [CoinColors.amberGold, CoinColors.amberGoldLight],
        ),
        borderRadius: Themes.boxRadius,
        boxShadow: [
          BoxShadow(
            color: CoinColors.accent.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: 40,
            top: 0,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 200,
            top: 80,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CoinColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.coins,
                      color: CoinColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.payment.paymentMethods.currentBalance,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              coinBalanceAsync.easyWhen(
                data: (coinData) => Text(
                  NumberFormat('#,###').format(coinData.coin),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                t.payment.paymentMethods.coinsLabel,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () {
                    context.router.push(const CoinPurchaseRoute());
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: CoinColors.accent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: Text(
                    t.payment.paymentMethods.buyCoin,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: CoinColors.accent,
                    ),
                  ),
                ),
              ),
            ],
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
      case 'question':
        return t.payment.paymentMethods.questionGeneration;
      default:
        return type;
    }
  }

  IconData _getRequestTypeIcon(String? type, Translations t) {
    if (type == null) return LucideIcons.circleQuestionMark;
    switch (type.toLowerCase()) {
      case 'image':
        return LucideIcons.image;
      case 'mindmap':
        return LucideIcons.network;
      case 'presentation':
        return LucideIcons.presentation;
      case 'question':
        return LucideIcons.fileQuestionMark;
      case 'outline':
        return LucideIcons.fileText;
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
