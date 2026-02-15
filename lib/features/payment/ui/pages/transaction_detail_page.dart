import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/features/payment/data/models/transaction_details_model.dart';

@RoutePage()
class TransactionDetailPage extends StatelessWidget {
  final TransactionDetailsModel transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.copy),
            tooltip: 'Copy Transaction ID',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: transaction.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction ID copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context),
            const SizedBox(height: 24),
            _buildAmountCard(context),
            const SizedBox(height: 24),
            _buildDetailsSection(context),
            const SizedBox(height: 24),
            _buildTimestampsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusMessage;

    switch (transaction.status) {
      case 'SUCCESS':
        statusColor = Colors.green;
        statusIcon = LucideIcons.circleCheck;
        statusMessage = 'Payment completed successfully';
        break;
      case 'PENDING':
        statusColor = Colors.orange;
        statusIcon = LucideIcons.clock;
        statusMessage = 'Payment is being processed';
        break;
      case 'FAILED':
        statusColor = Colors.red;
        statusIcon = LucideIcons.circleX;
        statusMessage = 'Payment failed';
        break;
      case 'CANCELLED':
        statusColor = Colors.grey;
        statusIcon = LucideIcons.ban;
        statusMessage = 'Payment was cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = LucideIcons.circleQuestionMark;
        statusMessage = 'Unknown status';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Column(
        children: [
          Icon(statusIcon, size: 64, color: statusColor),
          const SizedBox(height: 16),
          Text(
            transaction.status,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            statusMessage,
            style: TextStyle(
              fontSize: 14,
              color: statusColor.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.wallet,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  currencyFormat.format(transaction.amount),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (transaction.coinsAwarded != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.coins,
                      size: 20,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${NumberFormat('#,###').format(transaction.coinsAwarded)} coins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Details',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              'Transaction ID',
              transaction.id,
              icon: LucideIcons.hash,
              copyable: true,
            ),
            const Divider(height: 24),
            if (transaction.description != null)
              _buildDetailRow(
                context,
                'Description',
                transaction.description!,
                icon: LucideIcons.fileText,
              ),
            if (transaction.description != null) const Divider(height: 24),
            if (transaction.referenceCode != null)
              _buildDetailRow(
                context,
                'Reference Code',
                transaction.referenceCode!,
                icon: LucideIcons.code,
                copyable: true,
              ),
            if (transaction.referenceCode != null) const Divider(height: 24),
            if (transaction.gateway != null)
              _buildDetailRow(
                context,
                'Payment Gateway',
                transaction.gateway!,
                icon: LucideIcons.creditCard,
              ),
            if (transaction.errorMessage != null) ...[
              const Divider(height: 24),
              _buildDetailRow(
                context,
                'Error Message',
                transaction.errorMessage!,
                icon: LucideIcons.circleAlert,
                isError: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampsSection(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              context,
              'Created',
              dateFormat.format(transaction.createdAt),
              LucideIcons.clock,
              Colors.blue,
            ),
            if (transaction.updatedAt != null) ...[
              const SizedBox(height: 12),
              _buildTimelineItem(
                context,
                'Last Updated',
                dateFormat.format(transaction.updatedAt!),
                LucideIcons.refreshCw,
                Colors.orange,
              ),
            ],
            if (transaction.completedAt != null) ...[
              const SizedBox(height: 12),
              _buildTimelineItem(
                context,
                'Completed',
                dateFormat.format(transaction.completedAt!),
                LucideIcons.circleCheck,
                Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
    bool copyable = false,
    bool isError = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: isError
                ? Colors.red
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isError ? Colors.red : null,
                ),
              ),
            ],
          ),
        ),
        if (copyable)
          IconButton(
            icon: const Icon(LucideIcons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied to clipboard'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    String label,
    String time,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
