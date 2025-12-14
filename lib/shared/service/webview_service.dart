import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

/// Custom InAppBrowser for handling session-based WebView navigation
class SessionBrowser extends InAppBrowser {
  final String sessionToken;
  final VoidCallback? onPageFinished;

  SessionBrowser({required this.sessionToken, this.onPageFinished});

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
    String sessionToken, {
    VoidCallback? onPageFinished,
  }) async {
    try {
      final uri = WebUri(url);

      // 1. SET THE COOKIE (Works on Android & iOS)
      // This injects the cookie directly into the WebView storage before the page loads.
      await CookieManager.instance().setCookie(
        url: uri,
        name: "sessionId",
        value: sessionToken,
        isHttpOnly: true,
        isSecure: true,
        domain: Uri.parse(url).host,
      );

      // 2. CLOSE PREVIOUS BROWSER INSTANCE if exists
      await _currentBrowser?.close();

      // 3. CREATE AND OPEN NEW BROWSER WITH SESSION
      _currentBrowser = SessionBrowser(
        sessionToken: sessionToken,
        onPageFinished: onPageFinished,
      );

      await _currentBrowser!.openUrlRequest(
        urlRequest: URLRequest(
          url: uri,
          // Add Authorization header for additional security layer
          headers: {'Authorization': 'Bearer $sessionToken'},
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
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            // User agent customization (optional)
            userAgent:
                'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
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

  /// Gets the current browser instance (for advanced use cases)
  SessionBrowser? get currentBrowser => _currentBrowser;
}
