import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

/// Custom InAppBrowser for handling session-based WebView navigation
class SessionBrowser extends InAppBrowser {
  final VoidCallback? onPageFinished;

  SessionBrowser({this.onPageFinished});

  @override
  Future onBrowserCreated() async {
    // Called when browser is created
  }

  @override
  Future onLoadStart(url) async {
    // Called when page starts loading
  }

  @override
  Future onLoadStop(url) async {
    // Called when page finishes loading
    onPageFinished?.call();
  }

  @override
  void onProgressChanged(progress) {
    // Track loading progress (0-100)
  }
}

class WebviewService {
  static final WebviewService _instance = WebviewService._internal();

  factory WebviewService() {
    return _instance;
  }

  WebviewService._internal();

  SessionBrowser? _currentBrowser;

  /// Launches a simple external URL without session management
  /// Use for: External links that don't require authentication
  static Future<void> launchExternalUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  /// Launches a React web app view with session token authentication
  /// Use for: Authenticated pages that require session management
  ///
  /// Parameters:
  ///   - [url]: The URL of the React web app to load
  ///   - [sessionToken]: The session token for authentication
  ///   - [onPageFinished]: Optional callback when page finishes loading
  ///
  /// Features:
  ///   - Sets session token as HTTP-only secure cookie
  ///   - Adds Authorization header with bearer token
  ///   - Enables JavaScript for React app functionality
  ///   - Supports DOM storage for app state persistence
  ///   - Full screen presentation on iOS
  ///
  /// Note: The sessionToken like this: access_token=; refresh_token=
  Future<void> launchWithSession(
    String url,
    String accessToken,
    String refreshToken, {
    VoidCallback? onPageFinished,
  }) async {
    try {
      final uri = WebUri(url);

      // Set access token cookie
      if (accessToken.isNotEmpty) {
        await CookieManager.instance().setCookie(
          url: uri,
          name: "access_token",
          value: accessToken,
          isHttpOnly: true,
          isSecure: true,
          domain: Uri.parse(url).host,
        );
      }

      // Set refresh token cookie
      if (refreshToken.isNotEmpty) {
        await CookieManager.instance().setCookie(
          url: uri,
          name: "refresh_token",
          value: refreshToken,
          isHttpOnly: true,
          isSecure: true,
          domain: Uri.parse(url).host,
        );
      }

      await _currentBrowser?.close();

      _currentBrowser = SessionBrowser(onPageFinished: onPageFinished);

      await _currentBrowser!.openUrlRequest(
        urlRequest: URLRequest(
          url: uri,
          // Add Authorization header for additional security layer
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
        settings: InAppBrowserClassSettings(
          browserSettings: InAppBrowserSettings(
            // UX Configuration
            hideUrlBar: false,
            hideToolbarTop: false,
            toolbarTopBackgroundColor: Colors.white,
            toolbarTopFixedTitle: 'Web View',
            presentationStyle: ModalPresentationStyle.OVER_FULL_SCREEN,
          ),
          webViewSettings: InAppWebViewSettings(
            // Enable JavaScript for React app to function
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
          ),
        ),
      );
    } catch (e) {
      throw Exception('Failed to launch web view with session: $e');
    }
  }

  /// Closes the current browser instance
  Future<void> closeBrowser() async {
    await _currentBrowser?.close();
    _currentBrowser = null;
  }

  /// Dispose service and cleanup all resources
  Future<void> dispose() async {
    await closeBrowser();
    await CookieManager.instance().deleteAllCookies();
  }

  /// Clear session data
  Future<void> clearSession() async {
    await CookieManager.instance().deleteAllCookies();
  }

  /// Gets the current browser instance (for advanced use cases)
  SessionBrowser? get currentBrowser => _currentBrowser;
}
