import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/features/payment/providers/payment_providers.dart';
import 'package:AIPrimary/features/payment/data/models/transaction_details_model.dart';
import 'package:AIPrimary/features/coins/data/models/coin_usage_transaction_model.dart';
import 'package:AIPrimary/features/coins/providers/coins_providers.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/shared/widgets/generic_filters_bar.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

@RoutePage()
class TransactionHistoryPage extends ConsumerStatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  ConsumerState<TransactionHistoryPage> createState() =>
      _TransactionHistoryPageState();
}

// Filter enums
enum TransactionStatus { completed, pending, failed, cancelled }

enum PaymentGateway { sepay, payos }

class _TransactionHistoryPageState extends ConsumerState<TransactionHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Filter state
  TransactionStatus? _selectedStatus;
  PaymentGateway? _selectedGateway;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TransactionDetailsModel> _getFilteredTransactions(
    List<TransactionDetailsModel> allTransactions,
  ) {
    var filtered = allTransactions;

    // Filter by status
    if (_selectedStatus != null) {
      final statusString = _selectedStatus!.name.toUpperCase();
      filtered = filtered
          .where((t) => t.status.toUpperCase() == statusString)
          .toList();
    }

    // Filter by gateway
    if (_selectedGateway != null) {
      final gatewayString = _selectedGateway!.name.toUpperCase();
      filtered = filtered
          .where((t) => t.gateway?.toUpperCase() == gatewayString)
          .toList();
    }

    return filtered;
  }

  String _getStatusDisplayName(TransactionStatus status) {
    final t = ref.read(translationsPod);
    switch (status) {
      case TransactionStatus.completed:
        return t.payment.status.success;
      case TransactionStatus.pending:
        return t.payment.status.pending;
      case TransactionStatus.failed:
        return t.payment.status.failed;
      case TransactionStatus.cancelled:
        return t.payment.status.cancelled;
    }
  }

  String _getGatewayDisplayName(PaymentGateway gateway) {
    final t = ref.read(translationsPod);
    switch (gateway) {
      case PaymentGateway.sepay:
        return t.payment.coinPurchase.gateways.bankTransfer;
      case PaymentGateway.payos:
        return t.payment.coinPurchase.gateways.qrCode;
    }
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return LucideIcons.circleCheck;
      case TransactionStatus.pending:
        return LucideIcons.clock;
      case TransactionStatus.failed:
        return LucideIcons.circleX;
      case TransactionStatus.cancelled:
        return LucideIcons.ban;
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedGateway = null;
    });
  }

  String _getCoinTypeLabel(String type) {
    final t = ref.read(translationsPod);
    switch (type) {
      case 'add':
        return t.payment.transactionHistory.coinUsage.typeLabels.add;
      case 'subtract':
        return t.payment.transactionHistory.coinUsage.typeLabels.subtract;
      default:
        return t.payment.transactionHistory.coinUsage.typeLabels.unknown;
    }
  }

  String _getCoinSourceLabel(String source) {
    final t = ref.read(translationsPod);
    final labels = t.payment.transactionHistory.coinUsage.sourceLabels;
    switch (source) {
      case 'sepay':
        return labels.sepay;
      case 'payos':
        return labels.payos;
      case 'outline':
        return labels.outline;
      case 'presentation':
        return labels.presentation;
      case 'mindmap':
        return labels.mindmap;
      case 'refine_mindmap_node':
        return labels.refineMindmapNode;
      case 'expand_mindmap_node':
        return labels.expandMindmapNode;
      case 'refine_mindmap_branch':
        return labels.refineMindmapBranch;
      case 'refine_content':
        return labels.refineContent;
      case 'transform_layout':
        return labels.transformLayout;
      case 'refine_element_text':
        return labels.refineElementText;
      case 'refine_combined_text':
        return labels.refineCombinedText;
      case 'image':
        return labels.image;
      default:
        return labels.unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.payment.transactionHistory.title),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          tabs: [
            Tab(
              text: t.payment.transactionHistory.tabs.transactions,
              icon: const Icon(LucideIcons.receipt, size: 20),
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
            Tab(
              text: t.payment.transactionHistory.tabs.coinUsage,
              icon: const Icon(LucideIcons.coins, size: 20),
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTransactionsTab(t), _buildCoinUsageTab(t)],
      ),
    );
  }

  Widget _buildTransactionsTab(dynamic t) {
    final transactionsAsync = ref.watch(userAllTransactionsProvider);

    return Column(
      children: [
        // Filters bar
        GenericFiltersBar(
          filters: [
            FilterConfig<TransactionStatus>(
              label: t.payment.transactionHistory.filters.status,
              icon: LucideIcons.info,
              selectedValue: _selectedStatus,
              options: TransactionStatus.values,
              displayNameBuilder: _getStatusDisplayName,
              iconBuilder: _getStatusIcon,
              onChanged: (status) {
                setState(() {
                  _selectedStatus = status;
                });
              },
            ),
            FilterConfig<PaymentGateway>(
              label: t.payment.transactionHistory.filters.gateway,
              icon: LucideIcons.creditCard,
              selectedValue: _selectedGateway,
              options: PaymentGateway.values,
              displayNameBuilder: _getGatewayDisplayName,
              onChanged: (gateway) {
                setState(() {
                  _selectedGateway = gateway;
                });
              },
            ),
          ],
          onClearFilters: _clearFilters,
        ),

        // Transactions list
        Expanded(
          child: transactionsAsync.when(
            data: (allTransactions) {
              if (allTransactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.receipt,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.payment.transactionHistory.noTransactions,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final filteredTransactions = _getFilteredTransactions(
                allTransactions,
              );
              final hasActiveFilters =
                  _selectedStatus != null || _selectedGateway != null;

              // Show "no results" message when filters don't match
              if (filteredTransactions.isEmpty && hasActiveFilters) {
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(userAllTransactionsProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.funnel,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              t
                                  .payment
                                  .transactionHistory
                                  .noMatchingTransactions,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t.payment.transactionHistory.tryDifferentFilters,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Show filtered results
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(userAllTransactionsProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return _TransactionListItem(
                      transaction: transaction,
                      onTap: () {
                        context.router.push(
                          TransactionDetailRoute(transaction: transaction),
                        );
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.circleAlert,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.payment.transactionHistory.error(error: error.toString()),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(userAllTransactionsProvider);
                    },
                    child: Text(t.payment.transactionHistory.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoinUsageTab(dynamic t) {
    final coinHistoryAsync = ref.watch(userAllCoinHistoryProvider);

    return coinHistoryAsync.when(
      data: (coinHistory) {
        if (coinHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.coins,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  t.payment.transactionHistory.coinUsage.noHistory,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userAllCoinHistoryProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: coinHistory.length,
            itemBuilder: (context, index) {
              final tx = coinHistory[index];
              return _CoinUsageListItem(
                transaction: tx,
                typeLabel: _getCoinTypeLabel(tx.type),
                sourceLabel: _getCoinSourceLabel(tx.source),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.circleAlert, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(t.payment.transactionHistory.error(error: error.toString())),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(userAllCoinHistoryProvider);
              },
              child: Text(t.payment.transactionHistory.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final TransactionDetailsModel transaction;
  final VoidCallback onTap;

  const _TransactionListItem({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    Color statusColor;
    IconData statusIcon;

    switch (transaction.status) {
      case 'SUCCESS':
      case 'COMPLETED':
        statusColor = Colors.green;
        statusIcon = LucideIcons.circleCheck;
        break;
      case 'PENDING':
        statusColor = Colors.orange;
        statusIcon = LucideIcons.clock;
        break;
      case 'FAILED':
        statusColor = Colors.red;
        statusIcon = LucideIcons.circleX;
        break;
      case 'CANCELLED':
        statusColor = Colors.grey;
        statusIcon = LucideIcons.ban;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = LucideIcons.circleQuestionMark;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        transaction.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    dateFormat.format(transaction.createdAt.toLocal()),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currencyFormat.format(transaction.amount),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (transaction.coinsAwarded != null)
                    Row(
                      children: [
                        Icon(
                          LucideIcons.coins,
                          size: 16,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${NumberFormat('#,###').format(transaction.coinsAwarded)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (transaction.gateway != null) ...[
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, child) {
                    final t = ref.watch(translationsPod);
                    return Text(
                      t.payment.transactionHistory.paymentMethod(
                        gateway: transaction.gateway!,
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    );
                  },
                ),
              ],
              if (transaction.errorMessage != null) ...[
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, child) {
                    final t = ref.watch(translationsPod);
                    return Text(
                      '${t.payment.transactionHistory.errorPrefix}: ${transaction.errorMessage}',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinUsageListItem extends StatelessWidget {
  final CoinUsageTransactionModel transaction;
  final String typeLabel;
  final String sourceLabel;

  const _CoinUsageListItem({
    required this.transaction,
    required this.typeLabel,
    required this.sourceLabel,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isAdd = transaction.type == 'add';
    final amountColor = isAdd ? Colors.green : Colors.red;
    final amountPrefix = isAdd ? '+' : '-';
    final typeColor = isAdd ? Colors.green : Colors.red;
    final typeBgColor = isAdd
        ? Colors.green.withValues(alpha: 0.1)
        : Colors.red.withValues(alpha: 0.1);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: typeBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      color: typeColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  dateFormat.format(transaction.createdAt.toLocal()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    sourceLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(LucideIcons.coins, size: 16, color: amountColor),
                    const SizedBox(width: 4),
                    Text(
                      '$amountPrefix${NumberFormat('#,###').format(transaction.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: amountColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
