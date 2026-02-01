import 'dart:convert';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/config/config.dart';
import 'package:AIPrimary/features/generate/states/controller_provider.dart';
import 'package:AIPrimary/shared/widgets/authenticated_webview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page that embeds the Vue app's /generation/:id route for real-time presentation generation
///
/// Flow:
/// 1. Creates presentation via API first (gets back presentationId)
/// 2. Stores generation request in localStorage for Vue to access
/// 3. Opens webview with /generation/:id
/// 4. Vue handles streaming and displays slides
@RoutePage()
class PresentationGenerationWebViewPage extends ConsumerStatefulWidget {
  const PresentationGenerationWebViewPage({super.key});

  @override
  ConsumerState<PresentationGenerationWebViewPage> createState() =>
      _PresentationGenerationWebViewPageState();
}

class _PresentationGenerationWebViewPageState
    extends ConsumerState<PresentationGenerationWebViewPage> {
  bool _isWebViewLoading = true;
  bool _isCreatingPresentation = true;
  bool _isGenerationComplete = false;
  String? _error;
  String? _presentationId;

  @override
  void initState() {
    super.initState();
    _createPresentation();
  }

  Future<void> _createPresentation() async {
    try {
      final formState = ref.read(presentationFormControllerProvider);

      // Get the selected theme from the themes provider
      SlideThemeDto? selectedTheme;
      final themeId = formState.themeId;
      if (themeId != null) {
        final themesValue = ref.read(slideThemesProvider);
        final themes = themesValue.asData?.value;
        if (themes != null && themes.isNotEmpty) {
          selectedTheme = themes.firstWhere(
            (t) => t.id == themeId,
            orElse: () => themes.first,
          );
        }
      }

      // Create presentation request DTO
      final createRequest = CreatePresentationRequestDto(
        title: formState.topic.isEmpty
            ? 'Untitled Presentation'
            : formState.topic,
        slides: [],
        isParsed: false,
        viewport: {'width': 1000.0, 'height': 562.5},
        theme: selectedTheme,
      );

      // Create presentation via API
      final remoteSource = ref.read(projectsRemoteSourceProvider);
      final response = await remoteSource.createPresentation(createRequest);

      if (mounted) {
        setState(() {
          _presentationId = response.data?.id;
          _isCreatingPresentation = false;
        });
      }
    } catch (e) {
      debugPrint('Error creating presentation: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isCreatingPresentation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    if (InAppWebViewPlatform.instance == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.generate.presentationGenerate.title)),
        body: const Center(
          child: Text(
            'WebView is not supported on this platform.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // Show loading while creating presentation
    if (_isCreatingPresentation) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Preparing...'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.router.pop(),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Creating presentation...'),
            ],
          ),
        ),
      );
    }

    // Show error if presentation creation failed
    if (_error != null || _presentationId == null) {
      return _buildErrorView();
    }

    // Build webview with presentation ID
    final url = '${Config.presentationBaseUrl}/generation/$_presentationId';

    if (kDebugMode) {
      debugPrint('Opening generation webview: $url');
    }

    return _buildWebViewScaffold(url);
  }

  Widget _buildErrorView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to Create Presentation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Unknown error occurred',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isCreatingPresentation = true;
                  });
                  _createPresentation();
                },
                child: const Text('Retry'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.router.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebViewScaffold(String url) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: Text(t.generate.presentationGenerate.generating),
=======
        title: Text(
          _isGenerationComplete ? 'Presentation' : 'Generating Presentation',
        ),
>>>>>>> e89d14e (feat: wip)
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              _isGenerationComplete ? context.router.pop() : _handleClose(),
        ),
      ),
      body: Stack(
        children: [
          AuthenticatedWebView(
            webViewUrl: url,
            enableZoom: false,
            onWebViewCreated: (controller) {
              _registerHandlers(controller);
            },
            onLoadStop: (controller, url) async {
              debugPrint('WebView page loaded');
              setState(() => _isWebViewLoading = false);

              // Store generation request in localStorage for Vue to access
              await _storeGenerationRequest(controller);
            },
            onReceivedError: (controller, request, error) {
              debugPrint('WebView error: ${error.description}');
            },
            onConsoleMessage: (controller, message) {
              debugPrint('[Generation] ${message.message}');
            },
          ),
          if (_isWebViewLoading)
            const Center(child: CircularProgressIndicator()),
          if (_error != null && !_isCreatingPresentation)
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
                    Text(
                      t.generate.customization.error,
                      style: const TextStyle(
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
                      child: Text(t.generate.presentationGenerate.goBack),
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
    // Handler: Generation completed (from Vue after processing all slides)
    controller.addJavaScriptHandler(
      handlerName: 'generationCompleted',
      callback: (args) {
        final data = args.isNotEmpty ? args[0] as Map<String, dynamic> : {};
        debugPrint('Generation completed: $data');

        if (data['success'] == true) {
          final slideCount = data['slideCount'] as int?;
          debugPrint('Successfully generated $slideCount slides');
          if (mounted) {
            setState(() {
              _isGenerationComplete = true;
            });
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

    final t = ref.read(translationsPod);
    final formState = ref.read(presentationFormControllerProvider);
    final formController = ref.read(
      presentationFormControllerProvider.notifier,
    );

    // Build the generation request
    try {
      final generationRequest = formController.toPresentationRequest();

      // Create a temporary presentation ID (will be replaced by backend)
      final tempPresentationId =
          'temp_${DateTime.now().millisecondsSinceEpoch}';

      // Build the presentation object structure
      final presentation = {
        'id': tempPresentationId,
        'title': formState.topic.isEmpty
            ? t.projects.untitled
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
      debugPrint('Error preparing or sending generation data: $e');
      if (mounted) {
        setState(() {
          _error = e is FormatException
              ? e.message
              : 'Failed to prepare generation request';
        });
      }
    }
  }

  void _handleClose() {
    final t = ref.read(translationsPod);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.generate.presentationGenerate.cancelGenerationTitle),
        content: Text(t.generate.presentationGenerate.cancelGenerationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.questionBank.continue_),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.router.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t.generate.presentationGenerate.cancelGeneration),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
