import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/const/resource.dart';
import 'package:datn_mobile/core/secure_storage/secure_storage_pod.dart';

/// A widget that renders an authenticated InAppWebView with session cookies.
///
/// This widget handles:
/// - Reading access and refresh tokens from secure storage
/// - Setting HTTP-only secure cookies for authentication
/// - Rendering the WebView only after cookies are set
/// - Proper WebView configuration for web app functionality
///
/// Designed to be reusable for different web views (Presentation, Mindmap, etc.)
class AuthenticatedWebView extends ConsumerStatefulWidget {
  const AuthenticatedWebView({
    super.key,
    required this.url,
    this.onWebViewCreated,
    this.onLoadStop,
    this.onReceivedError,
    this.additionalHeaders,
  });

  final String url;
  final void Function(InAppWebViewController controller)? onWebViewCreated;
  final Future<void> Function(InAppWebViewController controller, WebUri? url)?
  onLoadStop;
  final void Function(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  )?
  onReceivedError;
  final Map<String, String>? additionalHeaders;

  @override
  ConsumerState<AuthenticatedWebView> createState() =>
      _AuthenticatedWebViewState();
}

class _AuthenticatedWebViewState extends ConsumerState<AuthenticatedWebView> {
  bool _areCookiesSet = false;

  @override
  void initState() {
    super.initState();
    _setupCookies();
  }

  Future<void> _setupCookies() async {
    final secureStorage = ref.read(secureStoragePod);
    final accessToken = await secureStorage.read(key: R.ACCESS_TOKEN_KEY);
    final refreshToken = await secureStorage.read(key: R.REFRESH_TOKEN_KEY);

    final uri = WebUri(widget.url);
    final domain = Uri.parse(widget.url).host;
    final cookieManager = CookieManager.instance();

    // Set access token cookie
    if (accessToken != null && accessToken.isNotEmpty) {
      await cookieManager.setCookie(
        url: uri,
        name: "access_token",
        value: accessToken,
        isHttpOnly: true,
        isSecure: true,
        domain: domain,
      );
    }

    // Set refresh token cookie
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await cookieManager.setCookie(
        url: uri,
        name: "refresh_token",
        value: refreshToken,
        isHttpOnly: true,
        isSecure: true,
        domain: domain,
      );

      if (kDebugMode) {
        print('Refresh token cookie set for domain: $domain');
      }
    }

    if (mounted) {
      setState(() {
        _areCookiesSet = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_areCookiesSet) {
      return const Center(child: CircularProgressIndicator());
    }

    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(widget.url),
        headers: widget.additionalHeaders,
      ),
      initialSettings: InAppWebViewSettings(
        // Enable JavaScript for web app functionality
        javaScriptEnabled: true,
        // Enable DOM storage for app state persistence
        domStorageEnabled: true,
        // Database storage for caching
        databaseEnabled: true,
        // Mixed content mode for Android
        mixedContentMode: MixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
        // User agent customization (optional)
        userAgent: Platform.isIOS
            ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1'
            : 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.106 Mobile Safari/537.36',
        // Load with overview mode
        loadWithOverviewMode: true,
        // Use wide viewport
        useWideViewPort: true,
        // Disable zoom controls
        displayZoomControls: false,
        // Support pinch zoom
        supportZoom: true,
        // Enable third-party cookies if needed
        thirdPartyCookiesEnabled: true,
        // Transparent background
        transparentBackground: false,
        // Hybrid composition for better performance
        useHybridComposition: true,
      ),
      onWebViewCreated: widget.onWebViewCreated,
      onLoadStop: widget.onLoadStop,
      onReceivedError: widget.onReceivedError,
    );
  }
}
