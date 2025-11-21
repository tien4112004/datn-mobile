import 'dart:convert';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:datn_mobile/features/projects/domain/entity/value_object/slide.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A widget that renders a presentation slide thumbnail using the
/// datn-fe-presentation.vercel.app/thumbnail endpoint.
///
/// This widget uses InAppWebView to communicate with a Vue.js component
/// that renders the slide thumbnail. It's designed for display only,
/// with no user interaction.
///
/// Example usage:
/// ```dart
/// PresentationThumbnail(
///   slide: mySlide,
///   width: 200,
///   height: 150,
/// )
/// ```
class PresentationThumbnail extends StatefulWidget {
  const PresentationThumbnail({
    super.key,
    required this.slide,
    this.width = 200,
    this.height = 150,
    this.showLoadingIndicator = true,
  });

  /// The slide to render as a thumbnail
  final Slide slide;

  /// Width of the thumbnail widget
  final double width;

  /// Height of the thumbnail widget
  final double height;

  /// Whether to show a loading indicator while the thumbnail loads
  final bool showLoadingIndicator;

  @override
  State<PresentationThumbnail> createState() => _PresentationThumbnailState();
}

class _PresentationThumbnailState extends State<PresentationThumbnail> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    // Fallback UI if InAppWebView is not available
    if (InAppWebViewPlatform.instance == null) {
      return ClipRRect(
        borderRadius: Themes.boxRadius,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.slide.background.color.isNotEmpty
                ? _parseColor(widget.slide.background.color)
                : Colors.grey.shade300,
          ),
          child: Center(
            child: Icon(
              LucideIcons.presentation,
              color: Colors.white.withValues(alpha: 0.7),
              size: widget.width * 0.4,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: Themes.boxRadius,
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.transparent,
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(
                  '${dotenv.env['PRESENTATION_BASEURL'] ?? 'https://datn-fe-presentation.vercel.app'}/thumbnail',
                ),
              ),
              initialSettings: InAppWebViewSettings(
                transparentBackground: true,
                disableContextMenu: true,
                supportZoom: false,
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                disableHorizontalScroll: true,
                disableVerticalScroll: true,
                useHybridComposition: true,
                allowsInlineMediaPlayback: true,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;

                // Add handler for thumbnailViewReady callback from Vue
                controller.addJavaScriptHandler(
                  handlerName: 'thumbnailViewReady',
                  callback: (args) {
                    _sendSlideData();
                  },
                );
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  _isLoading = false;
                });
                // Send slide data after page loads
                _sendSlideData();
              },
              onReceivedError: (controller, request, error) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                });
              },
              onConsoleMessage: (controller, consoleMessage) {
                // Optional: Handle console messages for debugging
                debugPrint('WebView Console: ${consoleMessage.message}');
              },
            ),

            // Loading indicator
            if (_isLoading && widget.showLoadingIndicator)
              Container(
                color: Colors.transparent,
                child: const Center(child: CircularProgressIndicator()),
              ),

            // Error state
            if (_hasError)
              Container(
                color: Colors.transparent,
                child: const Center(
                  child: Icon(
                    Icons.error_outline,
                    size: 32,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Sends the slide data to the Vue.js component via InAppWebView
  Future<void> _sendSlideData() async {
    if (_webViewController == null) return;

    try {
      // Send data via postMessage to Vue component
      await _webViewController!.evaluateJavascript(
        source:
            '''
        window.postMessage({
          type: 'setSlideData',
          data: {
            slideData: ${jsonEncode(widget.slide.toJson())},
            slideIndex: 0
          }
        }, '*');
      ''',
      );

      // Also set thumbnail size
      await _webViewController!.evaluateJavascript(
        source:
            '''
        if (window.setThumbnailSize) {
          window.setThumbnailSize(${widget.width});
        }
      ''',
      );

      setState(() {
        _hasError = false;
      });
    } catch (e) {
      debugPrint('Error sending slide data: $e');
      setState(() {
        _hasError = true;
      });
    }
  }

  /// Parses a color string (hex format) to a Flutter Color
  Color _parseColor(String colorString) {
    try {
      final hexColor = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return Colors.grey.shade300;
    }
  }

  @override
  void dispose() {
    _webViewController = null;
    super.dispose();
  }
}
