import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/const/resource.dart';
import 'package:AIPrimary/core/secure_storage/secure_storage_pod.dart';

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
    this.transparentBackground = false,
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
  final bool transparentBackground;

  @override
  ConsumerState<AuthenticatedWebView> createState() =>
      _AuthenticatedWebViewState();
}

class _AuthenticatedWebViewState extends ConsumerState<AuthenticatedWebView> {
  String? _accessToken;
  bool _tokenLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final secureStorage = ref.read(secureStoragePod);
    final token = await secureStorage.read(key: R.ACCESS_TOKEN_KEY);
    debugPrint(
      '[AuthWebView] Access token loaded: ${token != null ? "Yes" : "No"}',
    );
    if (mounted) {
      setState(() {
        _accessToken = token;
        _tokenLoaded = true;
      });
    }
  }

  /// Builds the user script that injects the token at document start,
  /// before any page scripts (including React) run.
  UnmodifiableListView<UserScript> _buildUserScripts() {
    if (_accessToken == null || _accessToken!.isEmpty) {
      return UnmodifiableListView([]);
    }
    return UnmodifiableListView([
      UserScript(
        source: "localStorage.setItem('access_token', '$_accessToken');",
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Wait until token is loaded before building the WebView, so
    // initialUserScripts can include the token from the very first load.
    if (!_tokenLoaded) {
      return const SizedBox.shrink();
    }

    debugPrint('[AuthWebView] Building WebView for URL: ${widget.webViewUrl}');

    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri.uri(Uri.parse(widget.webViewUrl)),
        headers: widget.additionalHeaders,
      ),
      initialUserScripts: _buildUserScripts(),
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
        overScrollMode: OverScrollMode.NEVER,
      ),
      onWebViewCreated: (controller) {
        debugPrint('[AuthWebView] WebView created');
        widget.onWebViewCreated?.call(controller);
      },
      onLoadStop: (controller, url) async {
        debugPrint('[AuthWebView] onLoadStop - URL: $url');
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
