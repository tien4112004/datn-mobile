import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/projects/domain/entity/presentation.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/widgets/authenticated_webview.dart';
import 'package:AIPrimary/core/config/config.dart';

/// A widget that renders a full presentation detail view using the
/// React app's PresentationEmbedPage.
///
/// This widget uses AuthenticatedWebView to display the presentation
/// in read-only mode for mobile devices with automatic authentication.
///
/// Key differences from previous implementation:
/// - Uses React's /presentation/embed/:id route instead of Vue's /mobile/:id
/// - React fetches presentation data via API (no postMessage needed)
/// - Supports CommentDrawer and permission handling from React
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
      resizeToAvoidBottomInset: false,
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
    // Use React's embed route instead of Vue's mobile route
    final locale = Localizations.localeOf(context).languageCode;
    final url =
        '${Config.mindmapBaseUrl}/presentation/embed/${presentation.id}?locale=$locale';

    return AuthenticatedWebView(
      webViewUrl: url,
      transparentBackground: true,
      onWebViewCreated: (controller) {
        // Register handler for presentationLoaded event from React
        controller.addJavaScriptHandler(
          handlerName: 'presentationLoaded',
          callback: (args) {
            if (args.isNotEmpty && args[0] is Map) {
              final data = args[0] as Map;
              final success = data['success'] as bool? ?? false;
              debugPrint(
                'Presentation loaded: success=$success, slideCount=${data['slideCount']}',
              );
              if (mounted) {
                setState(() => _isWebViewLoading = false);
              }
            }
          },
        );
      },
      onReceivedError: (controller, request, error) {
        debugPrint('WebView error: $error');
        if (mounted) {
          setState(() => _isWebViewLoading = false);
        }
      },
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 16,
      left: 16,
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
}
