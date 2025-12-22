import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/config/config.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/shared/widgets/authenticated_webview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page that embeds the Vue app's /generation route for real-time presentation generation
///
/// This page:
/// - Opens the generation view in an authenticated WebView
/// - Sends presentation data and generation request to the Vue app
/// - Handles callbacks from the Vue app (ready, started, completed)
/// - Navigates to presentation detail on successful completion
@RoutePage()
class PresentationGenerationWebViewPage extends ConsumerStatefulWidget {
  const PresentationGenerationWebViewPage({super.key});

  @override
  ConsumerState<PresentationGenerationWebViewPage> createState() =>
      _PresentationGenerationWebViewPageState();
}

class _PresentationGenerationWebViewPageState
    extends ConsumerState<PresentationGenerationWebViewPage> {
  InAppWebViewController? _webViewController;
  String? _error;
  String? _generatedPresentationId;

  @override
  Widget build(BuildContext context) {
    if (InAppWebViewPlatform.instance == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Generate Presentation')),
        body: const Center(
          child: Text(
            'WebView is not supported on this platform.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    if (kDebugMode) {
      print(
        'Call to build PresentationGenerationWebViewPage ${Config.presentationBaseUrl}/generation',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generating Presentation'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleClose(),
        ),
      ),
      body: Stack(
        children: [
          AuthenticatedWebView(
            url: '${Config.presentationBaseUrl}/generation',
            onWebViewCreated: (controller) {
              _webViewController = controller;
              _registerHandlers(controller);
            },
            onLoadStop: (controller, url) async {
              debugPrint('Generation page loaded: $url');
            },
            onReceivedError: (controller, request, error) {
              debugPrint('WebView error: $error');
              if (mounted) {
                setState(() {
                  _error = error.description;
                });
              }
            },
          ),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Generation Error',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.router.pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _registerHandlers(InAppWebViewController controller) {
    // Handler 1: Vue app is ready to receive data
    controller.addJavaScriptHandler(
      handlerName: 'generationViewReady',
      callback: (args) {
        debugPrint('Generation view ready, sending data...');
        _sendGenerationData();
      },
    );

    // Handler 2: Generation has started
    controller.addJavaScriptHandler(
      handlerName: 'generationStarted',
      callback: (args) {
        final data = args.isNotEmpty ? args[0] as Map<String, dynamic> : {};
        debugPrint('Generation started: $data');

        if (mounted) {
          setState(() {});
        }

        if (data['success'] == true) {
          _generatedPresentationId = data['presentationId'] as String?;
        } else {
          if (mounted) {
            setState(() {
              _error = data['error'] as String? ?? 'Failed to start generation';
            });
          }
        }
      },
    );

    // Handler 3: Generation completed
    controller.addJavaScriptHandler(
      handlerName: 'generationCompleted',
      callback: (args) {
        final data = args.isNotEmpty ? args[0] as Map<String, dynamic> : {};
        debugPrint('Generation completed: $data');

        if (data['success'] == true) {
          final slideCount = data['slideCount'] as int?;
          debugPrint('Successfully generated $slideCount slides');

          // Navigate to presentation detail or projects list
          if (mounted) {
            context.router.popUntilRouteWithName(MainWrapperRoute.name);
            // Optionally navigate to the presentation detail
            if (_generatedPresentationId != null) {
              context.router.push(
                PresentationDetailRoute(
                  presentationId: _generatedPresentationId!,
                ),
              );
            }
          }
        } else {
          if (mounted) {
            setState(() {
              _error = data['error'] as String? ?? 'Generation failed';
            });
          }
        }
      },
    );
  }

  Future<void> _sendGenerationData() async {
    if (_webViewController == null) return;

    final formState = ref.read(presentationFormControllerProvider);
    final formController = ref.read(
      presentationFormControllerProvider.notifier,
    );

    // Build the generation request
    final generationRequest = formController.toPresentationRequest(ref);

    // Create a temporary presentation ID (will be replaced by backend)
    final tempPresentationId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    // Build the presentation object structure
    final presentation = {
      'id': tempPresentationId,
      'title': formState.topic.isEmpty
          ? 'Untitled Presentation'
          : formState.topic,
      'slides': [], // Start with empty slides
      'theme': generationRequest.presentation?['theme'],
      'viewport': generationRequest.presentation?['viewport'],
    };

    // Build the complete generation request payload
    final generationPayload = {
      'presentationId': tempPresentationId,
      'outline': generationRequest.outline,
      'model': {
        'name': generationRequest.model,
        'provider': generationRequest.provider,
      },
      'slideCount': generationRequest.slideCount,
      'language': generationRequest.language,
      'presentation': generationRequest.presentation,
      'others': generationRequest.others,
    };

    try {
      // Send data to Vue app using the setGenerationData function
      await _webViewController!.evaluateJavascript(
        source:
            '''
          (function() {
            try {
              if (window.setGenerationData) {
                window.setGenerationData(
                  ${jsonEncode(presentation)},
                  ${jsonEncode(generationPayload)}
                );
                return 'Data sent successfully';
              } else {
                return 'setGenerationData not available yet';
              }
            } catch (error) {
              console.error('Error sending generation data:', error);
              return 'Error: ' + error.message;
            }
          })();
        ''',
      );
      debugPrint('Generation data sent to Vue app');
    } catch (e) {
      debugPrint('Error sending generation data: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to communicate with generation service';
        });
      }
    }
  }

  void _handleClose() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Generation?'),
        content: const Text(
          'Are you sure you want to cancel the presentation generation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.router.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Generation'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _webViewController = null;
    super.dispose();
  }
}
