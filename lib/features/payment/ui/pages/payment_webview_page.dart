import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/features/payment/data/models/payment_callback_result_model.dart';
import 'package:AIPrimary/features/payment/providers/payment_providers.dart';

@RoutePage()
class PaymentWebViewPage extends ConsumerStatefulWidget {
  final String checkoutUrl;
  final String transactionId;
  final Map<String, String>? formFields;

  const PaymentWebViewPage({
    super.key,
    required this.checkoutUrl,
    required this.transactionId,
    this.formFields,
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
            debugPrint('🌐 Page started loading: $url');
            setState(() {
              currentUrl = url;
              isLoading = true;
            });
          },
          onPageFinished: (url) {
            debugPrint('✅ Page finished loading: $url');
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (request) {
            debugPrint('📍 Navigation request: ${request.url}');
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
          onWebResourceError: (error) {
            debugPrint('❌ WebView error: ${error.description}');
            debugPrint('   Error type: ${error.errorType}');
            debugPrint('   URL: ${error.url}');
          },
        ),
      );

    // If formFields are provided, generate and submit HTML form
    if (widget.formFields != null && widget.formFields!.isNotEmpty) {
      final html = _generateAutoSubmitForm();
      _controller.loadHtmlString(html);
    } else {
      // Otherwise, just load the URL directly
      _controller.loadRequest(Uri.parse(widget.checkoutUrl));
    }
  }

  String _generateAutoSubmitForm() {
    // Properly escape HTML attribute values
    String escapeHtml(String value) {
      return value
          .replaceAll('&', '&amp;')
          .replaceAll('"', '&quot;')
          .replaceAll("'", '&#39;')
          .replaceAll('<', '&lt;')
          .replaceAll('>', '&gt;');
    }

    final formInputs = widget.formFields!.entries
        .map(
          (entry) =>
              '<input type="hidden" name="${escapeHtml(entry.key)}" value="${escapeHtml(entry.value)}">',
        )
        .join('\n        ');

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Content-Security-Policy" content="default-src * 'unsafe-inline' 'unsafe-eval' data: blob:; script-src * 'unsafe-inline' 'unsafe-eval'; style-src * 'unsafe-inline'; img-src * data: blob:; font-src * data:; connect-src *;">
    <title>Processing Payment...</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            text-align: center;
            padding: 2rem;
        }
        .spinner {
            width: 50px;
            height: 50px;
            margin: 20px auto;
            border: 4px solid rgba(255, 255, 255, 0.3);
            border-top: 4px solid white;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        h2 {
            margin: 0 0 10px 0;
            font-size: 24px;
        }
        p {
            margin: 0;
            opacity: 0.9;
            font-size: 14px;
        }
        .debug {
            margin-top: 20px;
            padding: 10px;
            background: rgba(0,0,0,0.2);
            border-radius: 8px;
            font-size: 12px;
            max-width: 90%;
            word-break: break-all;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="spinner"></div>
        <h2>Redirecting to Payment Gateway</h2>
        <p>Please wait while we redirect you...</p>
        <div class="debug" id="debugInfo"></div>
    </div>
    <form id="paymentForm" action="${escapeHtml(widget.checkoutUrl)}" method="POST" accept-charset="UTF-8">
        $formInputs
    </form>
    <script>
        // Debug: Show form action
        document.getElementById('debugInfo').innerHTML = 'Submitting to: ${escapeHtml(widget.checkoutUrl)}';

        // Auto-submit the form after a brief delay
        window.onload = function() {
            console.log('Form data:');
            var form = document.getElementById('paymentForm');
            var formData = new FormData(form);
            for (var pair of formData.entries()) {
                console.log(pair[0] + ': ' + pair[1]);
            }

            setTimeout(function() {
                try {
                    document.getElementById('debugInfo').innerHTML += '<br>Submitting form...';
                    form.submit();
                } catch(e) {
                    document.getElementById('debugInfo').innerHTML += '<br>Error: ' + e.message;
                    console.error('Form submission error:', e);
                }
            }, 1000);
        };
    </script>
</body>
</html>
    ''';
  }

  void _handleSuccess(Uri uri) async {
    // Wait a moment for backend webhook to process
    await Future.delayed(const Duration(seconds: 2));

    // Verify transaction status
    try {
      final transaction = await ref.read(
        transactionDetailsProvider(widget.transactionId).future,
      );

      if (!mounted) return;

      final result = PaymentCallbackResultModel(
        status: transaction.status == 'SUCCESS'
            ? PaymentCallbackStatus.success
            : PaymentCallbackStatus.pending,
        transactionId: widget.transactionId,
        message: transaction.status == 'SUCCESS'
            ? 'Payment completed successfully!'
            : 'Payment is being processed. Please check back later.',
      );

      context.router.pop(result);
    } catch (e) {
      if (!mounted) return;

      // Even if verification fails, assume success
      context.router.pop(
        const PaymentCallbackResultModel(
          status: PaymentCallbackStatus.pending,
          transactionId: null,
          message: 'Payment received. Please wait for confirmation.',
        ),
      );
    }
  }

  void _handleError(Uri uri) {
    final code = uri.queryParameters['code'];
    context.router.pop(
      PaymentCallbackResultModel(
        status: PaymentCallbackStatus.error,
        transactionId: widget.transactionId,
        message: 'Payment failed${code != null ? ' (Error: $code)' : ''}',
      ),
    );
  }

  void _handleCancel(Uri uri) {
    context.router.pop(
      const PaymentCallbackResultModel(
        status: PaymentCallbackStatus.cancelled,
        transactionId: null,
        message: 'Payment was cancelled',
      ),
    );
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
