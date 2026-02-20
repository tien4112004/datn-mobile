import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/features/payment/providers/payment_providers.dart';
import 'package:AIPrimary/features/payment/data/models/transaction_details_model.dart';
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

class _TransactionHistoryPageState
    extends ConsumerState<TransactionHistoryPage> {
  // Filter state
  TransactionStatus? _selectedStatus;
  PaymentGateway? _selectedGateway;

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

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final transactionsAsync = ref.watch(userAllTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.payment.transactionHistory.title)),
      body: Column(
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
                allLabel: t.payment.transactionHistory.filters.allStatus,
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
                allLabel: t.payment.transactionHistory.filters.allGateways,
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
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
                                t
                                    .payment
                                    .transactionHistory
                                    .tryDifferentFilters,
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
                      t.payment.transactionHistory.error(
                        error: error.toString(),
                      ),
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

    debugPrint(transaction.status);

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
                    dateFormat.format(transaction.createdAt),
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
