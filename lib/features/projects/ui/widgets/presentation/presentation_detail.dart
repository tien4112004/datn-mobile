import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/projects/domain/entity/presentation.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/widgets/authenticated_webview.dart';
import 'package:AIPrimary/core/config/config.dart';

/// A widget that renders a full presentation detail view using the
/// datn-fe-presentation web app.
///
/// This widget uses AuthenticatedWebView to display the complete presentation editor
/// in read-only mode for mobile devices with automatic authentication.
///
/// Handles loading and error states internally.
class PresentationDetail extends ConsumerStatefulWidget {
  const PresentationDetail({
    super.key,
    required this.presentationAsync,
    this.onClose,
    this.onRetry,
  });

  final AsyncValue<Presentation> presentationAsync;
  final VoidCallback? onClose;
  final VoidCallback? onRetry;

  @override
  ConsumerState<PresentationDetail> createState() => _PresentationDetailState();
}

class _PresentationDetailState extends ConsumerState<PresentationDetail> {
  InAppWebViewController? _webViewController;
  bool _isWebViewLoading = true;

  @override
  Widget build(BuildContext context) {
    if (InAppWebViewPlatform.instance == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Presentation Detail')),
        body: const Center(
          child: Text(
            'WebView is not supported on this platform.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return widget.presentationAsync.easyWhen(
      data: _buildContent,
      loadingWidget: _buildLoading,
      errorWidget: (error, stackTrace) => _buildError(error),
      onRetry: widget.onRetry,
    );
  }

  Widget _buildContent(Presentation presentation) {
    return Scaffold(
      appBar: AppBar(title: Text(presentation.title)),
      body: SafeArea(
        child: Stack(
          children: [
            _buildWebView(presentation),
            if (_isWebViewLoading)
              Container(
                color: Colors.white,
                child: const Center(child: CircularProgressIndicator()),
              ),
            if (widget.onClose != null) _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading presentation...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (widget.onClose != null) _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.circleAlert,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load presentation',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  if (widget.onRetry != null) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: widget.onRetry,
                      icon: const Icon(LucideIcons.rotateCw),
                      label: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.onClose != null) _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildWebView(Presentation presentation) {
    final url = '${Config.presentationBaseUrl}/mobile';

    return AuthenticatedWebView(
      webViewUrl: url,
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },
      onLoadStop: (controller, _) async {
        // Give the Vue app a moment to initialize
        await Future.delayed(const Duration(milliseconds: 500));
        await _sendPresentationData(presentation);
      },
      onReceivedError: (controller, request, error) {
        debugPrint('WebView error: $error');
        if (mounted) {
          setState(() => _isWebViewLoading = false);
        }
      },
    );
  }

  Future<void> _sendPresentationData(Presentation presentation) async {
    if (_webViewController == null) return;

    try {
      await _webViewController!.evaluateJavascript(
        source:
            '''
        window.postMessage({
          type: 'setPresentationData',
          data: {
            presentation: ${jsonEncode(presentation.toJson())},
            isMobile: true
          }
        }, '*');
      ''',
      );

      setState(() => _isWebViewLoading = false);
    } catch (e) {
      debugPrint('Error sending presentation data: $e');
    }
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: !_isWebViewLoading ? 48 : 8,
      right: 8,
      child: Material(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        child: InkWell(
          onTap: widget.onClose,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(LucideIcons.x, size: 20, color: Colors.grey.shade700),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _webViewController = null;
    super.dispose();
  }
}
