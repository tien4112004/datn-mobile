import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/features/payment/providers/payment_providers.dart';
import 'package:AIPrimary/features/payment/ui/widgets/coin_package_card.dart';
import 'package:AIPrimary/features/payment/data/models/payment_callback_result_model.dart';
import 'package:AIPrimary/features/payment/data/models/checkout_request_model.dart';
import 'package:AIPrimary/features/coins/providers/coins_providers.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/core/config/config.dart';
import 'package:AIPrimary/i18n/strings.g.dart';

@RoutePage()
class CoinPurchasePage extends ConsumerStatefulWidget {
  const CoinPurchasePage({super.key});

  @override
  ConsumerState<CoinPurchasePage> createState() => _CoinPurchasePageState();
}

class _CoinPurchasePageState extends ConsumerState<CoinPurchasePage> {
  String? selectedPackageId;
  String selectedGateway = 'SEPAY'; // Default gateway
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final packages = ref.watch(coinPackagesProvider);
    final t = ref.watch(translationsPod);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.payment.coinPurchase.title),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.history),
            onPressed: () {
              context.router.push(const TransactionHistoryRoute());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Payment Gateway Selection
                Text(
                  t.payment.coinPurchase.paymentMethod,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGatewayCard(
                        'SEPAY',
                        t.payment.coinPurchase.gateways.bankTransfer,
                        LucideIcons.building,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGatewayCard(
                        'PAYOS',
                        t.payment.coinPurchase.gateways.qrCode,
                        LucideIcons.qrCode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Text(
                  t.payment.coinPurchase.choosePackage,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.payment.coinPurchase.choosePackageSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 24),

                ...packages.map((package) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CoinPackageCard(
                      package: package,
                      isSelected: selectedPackageId == package.id,
                      onTap: () {
                        setState(() {
                          selectedPackageId = package.id;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // Bottom purchase button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedPackageId != null && !isProcessing
                      ? () => _handlePurchase(t)
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          t.payment.coinPurchase.continueToPayment,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(Translations t) async {
    if (selectedPackageId == null) return;

    setState(() {
      isProcessing = true;
    });

    try {
      final packages = ref.read(coinPackagesProvider);
      final selectedPackage = packages.firstWhere(
        (p) => p.id == selectedPackageId,
      );

      // Generate unique reference code
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final referenceCode =
          'COIN_${selectedPackage.id.toUpperCase()}_$timestamp';

      // Prepare checkout request with all fields
      final request = CheckoutRequestModel(
        amount: selectedPackage.price,
        description: '${selectedPackage.name} - ${selectedPackage.coins} coins',
        referenceCode: referenceCode,
        gate: selectedGateway,
        successUrl: '${Config.baseUrl}/payments/callback/success',
        errorUrl: '${Config.baseUrl}/payments/callback/error',
        cancelUrl: '${Config.baseUrl}/payments/callback/cancel',
      );

      // Create checkout
      final checkoutResponse = await ref.read(
        createCheckoutProvider(request).future,
      );

      if (!mounted) return;

      // Navigate to WebView with checkout URL and form fields
      final result = await context.router.push<PaymentCallbackResultModel>(
        PaymentWebViewRoute(
          checkoutUrl: checkoutResponse.checkoutUrl,
          transactionId: checkoutResponse.transactionId,
          formFields: checkoutResponse.formFields,
        ),
      );

      if (!mounted) return;

      // Handle result
      if (result != null) {
        _handlePaymentResult(result, t);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.payment.coinPurchase.failedToCreateCheckout(error: e.toString()),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  void _handlePaymentResult(PaymentCallbackResultModel result, Translations t) {
    switch (result.status) {
      case PaymentCallbackStatus.success:
        // Invalidate coin balance to refresh
        ref.invalidate(userCoinBalanceProvider);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(
              LucideIcons.circleCheck,
              color: Colors.green,
              size: 64,
            ),
            title: Text(t.payment.callback.paymentSuccessful),
            content: Text(result.message ?? t.payment.callback.coinsAdded),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.router.pop(); // Return to previous page
                },
                child: Text(t.payment.callback.ok),
              ),
            ],
          ),
        );
        break;

      case PaymentCallbackStatus.error:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? t.payment.callback.paymentFailed),
            backgroundColor: Colors.red,
          ),
        );
        break;

      case PaymentCallbackStatus.cancelled:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.payment.callback.paymentCancelled)),
        );
        break;

      case PaymentCallbackStatus.pending:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.payment.callback.paymentPending)),
        );
        break;
    }
  }

  Widget _buildGatewayCard(String gateway, String label, IconData icon) {
    final isSelected = selectedGateway == gateway;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedGateway = gateway;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                Icon(
                  LucideIcons.check,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
