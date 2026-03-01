import 'package:AIPrimary/core/config/config.dart';
import 'package:AIPrimary/features/projects/ui/widgets/desktop_hint_button.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/widgets/authenticated_webview.dart';
import 'package:AIPrimary/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final t = ref.watch(translationsPod);

    if (InAppWebViewPlatform.instance == null) {
      return Scaffold(
        body: Center(
          child: Text(
            t.projects.mindmaps.webViewNotSupported,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return _buildContent(mindmapId: widget.mindmapId);
  }

  Widget _buildContent({required String mindmapId}) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const CustomAppBar(title: 'Mindmap Detail'),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            _buildWebView(mindmapId: widget.mindmapId),
            if (_isWebViewLoading)
              Container(
                color: Colors.white,
                child: const Center(child: CircularProgressIndicator()),
              ),
            const DesktopHintDialog(),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildLoading() {
    final t = ref.watch(translationsPod);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    t.projects.mindmaps.loadingMindmap,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebView({required String mindmapId}) {
    final locale = ref.read(translationsPod).$meta.locale.languageCode;
    final url =
        '${Config.mindmapBaseUrl}/mindmap/embed/$mindmapId?locale=$locale';
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
