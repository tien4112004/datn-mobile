import 'package:AIPrimary/core/config/config.dart';
import 'package:AIPrimary/shared/widgets/authenticated_webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MindmapDetail extends ConsumerStatefulWidget {
  final String mindmapId;
  final VoidCallback? onClose;
  final VoidCallback? onRetry;

  const MindmapDetail({
    super.key,
    required this.mindmapId,
    required this.onClose,
    required this.onRetry,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MindmapDetailState();
}

class _MindmapDetailState extends ConsumerState<MindmapDetail> {
  bool _isWebViewLoading = true;

  @override
  Widget build(BuildContext context) {
    if (InAppWebViewPlatform.instance == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'WebView is not supported on this platform.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return _buildContent(mindmapId: widget.mindmapId);
  }

  Widget _buildContent({required String mindmapId}) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(child: _buildWebView(mindmapId: widget.mindmapId)),
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

  // ignore: unused_element
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

  Widget _buildWebView({required String mindmapId}) {
    final url = '${Config.mindmapBaseUrl}/mindmap/embed/$mindmapId';
    return AuthenticatedWebView(
      webViewUrl: url,
      enableZoom: false,
      onWebViewCreated: (controller) {
        debugPrint('WebView created for mindmap: $mindmapId');
      },
      onLoadStop: (controller, url) async {
        setState(() {
          _isWebViewLoading = false;
        });
      },
      onReceivedError: (controller, request, error) {
        debugPrint('WebView error: ${error.description}');
      },
      onConsoleMessage: (controller, message) {
        debugPrint(
          '[Mindmap WebApp] [${message.messageLevel.toString()}] ${message.message}',
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
