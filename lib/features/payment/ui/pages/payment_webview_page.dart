import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/features/payment/data/models/payment_callback_result_model.dart';
import 'package:AIPrimary/features/payment/data/models/transaction_details_model.dart';
import 'package:AIPrimary/features/payment/domain/exceptions/payment_exceptions.dart';
import 'package:AIPrimary/features/payment/providers/payment_providers.dart';
import 'package:AIPrimary/i18n/strings.g.dart';

@RoutePage()
class PaymentWebViewPage extends ConsumerStatefulWidget {
  final String checkoutUrl;
  final String transactionId;

  const PaymentWebViewPage({
    super.key,
    required this.checkoutUrl,
    required this.transactionId,
  });

  @override
  ConsumerState<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends ConsumerState<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool isLoading = true;
  String currentUrl = '';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              currentUrl = url;
              isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (request) {
            final uri = Uri.parse(request.url);

            // Check for callback URLs
            if (uri.path.contains('/payments/callback/success')) {
              _handleSuccess(uri);
              return NavigationDecision.prevent;
            } else if (uri.path.contains('/payments/callback/error')) {
              _handleError(uri);
              return NavigationDecision.prevent;
            } else if (uri.path.contains('/payments/callback/cancel')) {
              _handleCancel(uri);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _handleSuccess(Uri uri) async {
    if (!mounted) return;

    // Show loading indicator
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(t.payment.webview.verifyingPayment),
          ],
        ),
        duration: const Duration(minutes: 2),
      ),
    );

    try {
      final pollingService = ref.read(paymentStatusPollingServiceProvider);

      // Poll with exponential backoff
      final transaction = await pollingService.pollTransactionStatus(
        transactionId: widget.transactionId,
        onRetry: (attempt, nextDelay) {
          debugPrint(
            'Payment verification attempt $attempt, waiting ${nextDelay.inSeconds}s...',
          );
        },
      );

      if (!mounted) return;

      // Clear loading indicator
      scaffoldMessenger.hideCurrentSnackBar();

      // Build result based on verified status
      final result = _buildCallbackResult(transaction);
      context.router.pop(result);
    } on PaymentTimeoutException {
      if (!mounted) return;
      scaffoldMessenger.hideCurrentSnackBar();

      // Show timeout message with helpful information
      context.router.pop(
        PaymentCallbackResultModel(
          status: PaymentCallbackStatus.pending,
          transactionId: widget.transactionId,
          message: t.payment.webview.messages.timeoutSuccess,
        ),
      );
    } on PaymentVerificationException {
      if (!mounted) return;
      scaffoldMessenger.hideCurrentSnackBar();

      // Show verification failure with retry suggestion
      context.router.pop(
        PaymentCallbackResultModel(
          status: PaymentCallbackStatus.pending,
          transactionId: widget.transactionId,
          message: t.payment.webview.messages.verificationFailed,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.hideCurrentSnackBar();

      // Unexpected error
      context.router.pop(
        PaymentCallbackResultModel(
          status: PaymentCallbackStatus.error,
          transactionId: widget.transactionId,
          message: t.payment.webview.messages.unexpectedError,
        ),
      );
    }
  }

  void _handleError(Uri uri) async {
    if (!mounted) return;

    // Show loading indicator
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(t.payment.webview.verifyingPayment),
          ],
        ),
        duration: const Duration(minutes: 2),
      ),
    );

    try {
      final pollingService = ref.read(paymentStatusPollingServiceProvider);

      // Poll to verify final status
      final transaction = await pollingService.pollTransactionStatus(
        transactionId: widget.transactionId,
        onRetry: (attempt, nextDelay) {
          debugPrint(
            'Payment verification attempt $attempt, waiting ${nextDelay.inSeconds}s...',
          );
        },
      );

      if (!mounted) return;

      // Clear loading indicator
      scaffoldMessenger.hideCurrentSnackBar();

      // Build result based on verified status
      final result = _buildCallbackResult(transaction);
      context.router.pop(result);
    } on PaymentTimeoutException {
      if (!mounted) return;
      scaffoldMessenger.hideCurrentSnackBar();

      final code = uri.queryParameters['code'];
      context.router.pop(
        PaymentCallbackResultModel(
          status: PaymentCallbackStatus.error,
          transactionId: widget.transactionId,
          message: code != null
              ? t.payment.webview.messages.failedWithCode(code: code)
              : t.payment.webview.messages.failedDefault,
        ),
      );
    } on PaymentVerificationException {
      if (!mounted) return;
      scaffoldMessenger.hideCurrentSnackBar();

      final code = uri.queryParameters['code'];
      context.router.pop(
        PaymentCallbackResultModel(
          status: PaymentCallbackStatus.error,
          transactionId: widget.transactionId,
          message: code != null
              ? t.payment.webview.messages.failedWithCode(code: code)
              : t.payment.webview.messages.failedDefault,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.hideCurrentSnackBar();

      final code = uri.queryParameters['code'];
      context.router.pop(
        PaymentCallbackResultModel(
          status: PaymentCallbackStatus.error,
          transactionId: widget.transactionId,
          message: code != null
              ? t.payment.webview.messages.failedWithCode(code: code)
              : t.payment.webview.messages.failedDefault,
        ),
      );
    }
  }

  void _handleCancel(Uri uri) async {
    if (!mounted) return;

    // Explicitly notify backend to mark transaction CANCELLED (best-effort)
    final repository = ref.read(paymentRepositoryProvider);
    await repository.cancelTransaction(widget.transactionId);

    if (!mounted) return;

    context.router.pop(
      PaymentCallbackResultModel(
        status: PaymentCallbackStatus.cancelled,
        transactionId: widget.transactionId,
        message: t.payment.webview.messages.cancelled,
      ),
    );

    try {
      final pollingService = ref.read(paymentStatusPollingServiceProvider);

      // Poll to verify final status
      final transaction = await pollingService.pollTransactionStatus(
        transactionId: widget.transactionId,
        onRetry: (attempt, nextDelay) {
          debugPrint(
            'Payment verification attempt $attempt, waiting ${nextDelay.inSeconds}s...',
          );
        },
      );

      if (!mounted) return;

      // Clear loading indicator
      scaffoldMessenger.hideCurrentSnackBar();

      // Build result based on verified status
      final result = _buildCallbackResult(transaction);
      context.router.pop(result);
    } on PaymentTimeoutException {
      if (!mounted) return;
      scaffoldMessenger.hideCurrentSnackBar();

      final code = uri.queryParameters['code'];
      context.router.pop(
        PaymentCallbackResultModel(
          status: PaymentCallbackStatus.error,
          transactionId: widget.transactionId,
          message:
              'Payment failed${code != null ? ' (Error: $code)' : ''}. Please try again.',
        ),
      );
    } on PaymentVerificationException {
      if (!mounted) return;
      scaffoldMessenger.hideCurrentSnackBar();

      final code = uri.queryParameters['code'];
      context.router.pop(
        PaymentCallbackResultModel(
          status: PaymentCallbackStatus.error,
          transactionId: widget.transactionId,
          message:
              'Payment failed${code != null ? ' (Error: $code)' : ''}. Please try again.',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.hideCurrentSnackBar();

      final code = uri.queryParameters['code'];
      context.router.pop(
        PaymentCallbackResultModel(
          status: PaymentCallbackStatus.error,
          transactionId: widget.transactionId,
          message:
              'Payment failed${code != null ? ' (Error: $code)' : ''}. Please try again.',
        ),
      );
    }
  }

  PaymentCallbackResultModel _buildCallbackResult(
    TransactionDetailsModel transaction,
  ) {
    switch (transaction.status) {
      case 'SUCCESS':
        return PaymentCallbackResultModel(
          status: PaymentCallbackStatus.success,
          transactionId: transaction.id,
          message: t.payment.webview.messages.successWithCoins(
            coins: transaction.coinsAwarded ?? 0,
          ),
        );
      case 'FAILED':
        return PaymentCallbackResultModel(
          status: PaymentCallbackStatus.error,
          transactionId: transaction.id,
          message:
              transaction.errorMessage ??
              t.payment.webview.messages.failedDefault,
        );
      case 'CANCELLED':
        return PaymentCallbackResultModel(
          status: PaymentCallbackStatus.cancelled,
          transactionId: transaction.id,
          message: t.payment.webview.messages.cancelled,
        );
      default:
        return PaymentCallbackResultModel(
          status: PaymentCallbackStatus.pending,
          transactionId: transaction.id,
          message: t.payment.webview.messages.processing,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cancel Payment?'),
                content: const Text(
                  'Are you sure you want to cancel this payment?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _handleCancel(Uri.parse(currentUrl));
                    },
                    child: const Text('Yes, Cancel'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
