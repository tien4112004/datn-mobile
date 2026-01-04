import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/const/resource.dart';
import 'package:datn_mobile/core/secure_storage/secure_storage_pod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

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
    try {
      debugPrint('Starting cookie setup for URL: ${widget.url}');

      final secureStorage = ref.read(secureStoragePod);
      final accessToken = await secureStorage.read(key: R.ACCESS_TOKEN_KEY);
      final refreshToken = await secureStorage.read(key: R.REFRESH_TOKEN_KEY);

      final uri = WebUri(widget.url);
      String domain = 'api.huy-devops.site';
      // if (uri.host != 'localhost') {
      //   debugPrint(
      //     'WARNING: The URL host is not localhost. Cookies may not be set correctly for cross-domain requests.',
      //   );
      //   final parts = uri.host.split('.');
      //   if (parts.length >= 2) {
      //     domain = '.${parts.sublist(parts.length - 2).join('.')}';
      //   }
      // }

      final cookieManager = CookieManager.instance();

      debugPrint('Setting cookies for URL: ${widget.url}');

      final accessTokenExpiry = JwtDecoder.getExpirationDate(accessToken!);
      // Set access token cookie (without explicit domain to let it auto-infer)
      if (accessToken.isNotEmpty) {
        await cookieManager
            .setCookie(
              url: uri,
              name: "access_token",
              value: accessToken,
              domain: domain,
              path: '/',
              expiresDate: accessTokenExpiry.millisecondsSinceEpoch,
              isHttpOnly: true,
              isSecure: true,
              sameSite: HTTPCookieSameSitePolicy.NONE,
            )
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                debugPrint('Access token cookie set timed out');
                return true;
              },
            );
        debugPrint('Access token cookie set successfully');
      }

      final refreshTokenExpiry = JwtDecoder.getExpirationDate(accessToken);
      // Set refresh token cookie
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await cookieManager
            .setCookie(
              url: uri,
              name: "refresh_token",
              value: refreshToken,
              domain: domain,
              path: '/',
              expiresDate: refreshTokenExpiry.millisecondsSinceEpoch,
              isHttpOnly: true,
              isSecure: true,
              sameSite: HTTPCookieSameSitePolicy.NONE,
            )
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                debugPrint('Refresh token cookie set timed out');
                return true;
              },
            );
        debugPrint('Refresh token cookie set successfully');
      }

      debugPrint('Cookie setup completed. Mounted: $mounted');

      if (mounted) {
        debugPrint('Calling setState to update _areCookiesSet');
        setState(() {
          _areCookiesSet = true;
        });
        debugPrint('setState completed, _areCookiesSet: $_areCookiesSet');
      } else {
        debugPrint('WARNING: Widget not mounted, cannot call setState');
      }
    } catch (e, stackTrace) {
      debugPrint('ERROR in _setupCookies: $e');
      debugPrint('Stack trace: $stackTrace');

      // Still set cookies as ready to prevent infinite loading
      if (mounted) {
        setState(() {
          _areCookiesSet = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building AuthenticatedWebView, cookies set: $_areCookiesSet');

    if (!_areCookiesSet) {
      return const Center(child: CircularProgressIndicator());
    }

    debugPrint('Cookies set, loading WebView for URL: ${widget.url}');

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
