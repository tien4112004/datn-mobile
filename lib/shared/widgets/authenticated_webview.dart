import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/const/resource.dart';
import 'package:datn_mobile/core/secure_storage/secure_storage_pod.dart';

/// A widget that renders an authenticated InAppWebView with token authentication.
///
/// This widget handles:
/// - Reading access token from secure storage
/// - Injecting token into webview's localStorage/cookies before app initializes
/// - Proper WebView configuration for web app functionality
///
/// The React webapp reads the token from localStorage (set by this widget)
/// to communicate with the backend server. This approach works with React Router
/// client-side navigation, unlike URL query parameters which get stripped.
///
/// Designed to be reusable for different web views (Presentation, Mindmap, etc.)
class AuthenticatedWebView extends ConsumerStatefulWidget {
  const AuthenticatedWebView({
    super.key,
    required this.webViewUrl,
    this.onWebViewCreated,
    this.onLoadStop,
    this.onReceivedError,
    this.onConsoleMessage,
    this.additionalHeaders,
    this.enableZoom = true,
  });

  final String webViewUrl;
  final void Function(InAppWebViewController controller)? onWebViewCreated;
  final Future<void> Function(InAppWebViewController controller, WebUri? url)?
  onLoadStop;
  final void Function(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  )?
  onReceivedError;
  final void Function(
    InAppWebViewController controller,
    ConsoleMessage message,
  )?
  onConsoleMessage;
  final Map<String, String>? additionalHeaders;
  final bool enableZoom;

  @override
  ConsumerState<AuthenticatedWebView> createState() =>
      _AuthenticatedWebViewState();
}

class _AuthenticatedWebViewState extends ConsumerState<AuthenticatedWebView> {
  String? _accessToken;
  bool _tokenInjected = false;

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final secureStorage = ref.read(secureStoragePod);
    _accessToken = await secureStorage.read(key: R.ACCESS_TOKEN_KEY);
    debugPrint('Access token loaded: ${_accessToken != null ? "Yes" : "No"}');
    if (mounted) {
      setState(() {});
    }
  }

  /// Injects the access token into the webview's localStorage
  /// This must be called before the React app initializes
  Future<void> _injectToken(InAppWebViewController controller) async {
    if (_accessToken == null || _accessToken!.isEmpty) {
      debugPrint('[AuthWebView] No token to inject');
      return;
    }

    if (_tokenInjected) {
      debugPrint('[AuthWebView] Token already injected, skipping');
      return;
    }

    try {
      // Inject token into localStorage
      await controller.evaluateJavascript(
        source:
            '''
        (function() {
          try {
            localStorage.setItem('access_token', '$_accessToken');
            console.info('[AuthWebView] Token injected into localStorage');
          } catch (e) {
            console.error('[AuthWebView] Failed to inject token:', e);
          }
        })();
      ''',
      );

      _tokenInjected = true;
      debugPrint('[AuthWebView] Token successfully injected into localStorage');
    } catch (e) {
      debugPrint('[AuthWebView] Error injecting token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building AuthenticatedWebView for URL: ${widget.webViewUrl}');

    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri.uri(Uri.parse(widget.webViewUrl)),
        headers: widget.additionalHeaders,
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
        userAgent: Platform.isIOS
            ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1'
            : 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.106 Mobile Safari/537.36',
        loadWithOverviewMode: true,
        useWideViewPort: true,
        displayZoomControls: false,
        supportZoom: widget.enableZoom,
        disallowOverScroll: true,
        verticalScrollBarEnabled: false,
        thirdPartyCookiesEnabled: true,
        transparentBackground: false,
        useHybridComposition: true,
      ),
      onWebViewCreated: (controller) {
        debugPrint('[AuthWebView] WebView created');
        widget.onWebViewCreated?.call(controller);
      },
      onLoadStart: (controller, url) async {
        debugPrint('[AuthWebView] onLoadStart - URL: $url');

        // Inject token into localStorage before React app initializes
        await _injectToken(controller);
      },
      onLoadStop: (controller, url) async {
        debugPrint('[AuthWebView] onLoadStop - URL: $url');

        // Debug: Check if token was successfully injected
        try {
          final hasTokenInStorage = await controller.evaluateJavascript(
            source: 'localStorage.getItem("access_token") !== null',
          );
          debugPrint('[AuthWebView] Token in localStorage: $hasTokenInStorage');

          if (hasTokenInStorage == true) {
            final tokenLength = await controller.evaluateJavascript(
              source: '(localStorage.getItem("access_token") || "").length',
            );
            debugPrint('[AuthWebView] Token length: $tokenLength');
          }
        } catch (e) {
          debugPrint('[AuthWebView] Error checking localStorage: $e');
        }

        await widget.onLoadStop?.call(controller, url);
      },
      onReceivedError: widget.onReceivedError,
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint(
          '[WebView Console] [${consoleMessage.messageLevel.toString()}] ${consoleMessage.message}',
        );
        widget.onConsoleMessage?.call(controller, consoleMessage);
      },
    );
  }
}
