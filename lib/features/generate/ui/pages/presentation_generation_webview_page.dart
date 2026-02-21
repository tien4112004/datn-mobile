import 'dart:convert';
import 'package:AIPrimary/features/generate/data/dto/slide_theme_dto.dart';
import 'package:AIPrimary/features/generate/states/theme/theme_provider.dart';
import 'package:AIPrimary/features/projects/data/dto/create_presentation_request_dto.dart';
import 'package:AIPrimary/features/projects/data/source/projects_remote_source_provider.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/config/config.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/generate/states/controller_provider.dart';
import 'package:AIPrimary/shared/widgets/authenticated_webview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page that embeds the Vue app's /generation/:id route for real-time presentation generation
///
/// Flow:
/// 1. Creates presentation via API (hidden behind loading)
/// 2. Opens WebView (hidden behind loading)
/// 3. Stores generation request in localStorage
/// 4. Waits for Vue to signal 'generationViewReady'
/// 5. Shows WebView with Vue's streaming UI
@RoutePage()
class PresentationGenerationWebViewPage extends ConsumerStatefulWidget {
  const PresentationGenerationWebViewPage({super.key});

  @override
  ConsumerState<PresentationGenerationWebViewPage> createState() =>
      _PresentationGenerationWebViewPageState();
}

class _PresentationGenerationWebViewPageState
    extends ConsumerState<PresentationGenerationWebViewPage> {
  bool _isVueReady = false;
  bool _isGenerationComplete = false;
  bool _isLoading = false;
  String? _error;
  String? _presentationId;

  @override
  void initState() {
    super.initState();
    _createPresentation();
  }

  Future<void> _createPresentation() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

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
      // Error handling is centralized in DefaultAPIInterceptor
      final remoteSource = ref.read(projectsRemoteSourceProvider);
      final response = await remoteSource.createPresentation(createRequest);

      if (!mounted) return;

      setState(() {
        _presentationId = response.data?.id;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error creating presentation: $e');
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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

    // Show error if presentation creation failed
    if (_error != null) {
      return _buildErrorView();
    }

    // Show loading while waiting for presentation ID
    if (_isLoading || _presentationId == null) {
      return _buildLoadingScaffold();
    }

    // Build WebView once we have the ID
    final locale = ref.read(translationsPod).$meta.locale.languageCode;
    final url =
        '${Config.presentationBaseUrl}/generation/$_presentationId?locale=$locale';

    if (kDebugMode) {
      debugPrint('Opening generation webview: $url');
    }

    return _buildWebViewScaffold(url);
  }

  Widget _buildLoadingScaffold() {
    final t = ref.watch(translationsPod);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.generate.presentationGenerate.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(t.generate.presentationGenerate.startingGeneration),
            const SizedBox(height: 8),
            Text(
              t.generate.presentationGenerate.generatingSubtitle,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    final t = ref.watch(translationsPod);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.generate.presentationGenerate.error),
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
              Text(
                t.generate.presentationGenerate.failedToCreatePresentation,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? t.generate.presentationGenerate.unknownError,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                  _createPresentation();
                },
                child: Text(t.generate.presentationGenerate.retry),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.router.pop(),
                child: Text(t.generate.presentationGenerate.goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebViewScaffold(String? url) {
    final t = ref.watch(translationsPod);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.generate.presentationGenerate.generating),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              _isGenerationComplete ? _navigateToProjects() : _handleClose(),
        ),
      ),
      body: Stack(
        children: [
          // WebView - hidden until Vue signals ready
          if (url != null)
            Opacity(
              opacity: _isVueReady ? 1.0 : 0.0,
              child: AuthenticatedWebView(
                webViewUrl: url,
                enableZoom: false,
                onWebViewCreated: (controller) {
                  _registerHandlers(controller);
                },
                onLoadStop: (controller, url) async {
                  debugPrint('WebView page loaded');
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
            ),

          // Single loading indicator - shown until Vue is ready
          if (!_isVueReady)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(t.generate.presentationGenerate.startingGeneration),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _storeGenerationRequest(
    InAppWebViewController controller,
  ) async {
    try {
      final formController = ref.read(
        presentationFormControllerProvider.notifier,
      );
      final request = formController.toPresentationRequest();

      // Build request body
      final requestBody = {
        'presentationId': _presentationId,
        'model': request.model,
        'provider': request.provider,
        'language': request.language,
        'slideCount': request.slideCount,
        'outline': request.outline,
        'presentation': request.presentation,
        'others': request.others,
        if (request.grade != null) 'grade': request.grade,
        if (request.subject != null) 'subject': request.subject,
      };

      final jsonString = jsonEncode(requestBody);

      // Escape for JavaScript
      final escapedJson = jsonString
          .replaceAll('\\', '\\\\')
          .replaceAll("'", "\\'")
          .replaceAll('\n', '\\n')
          .replaceAll('\r', '\\r');

      await controller.evaluateJavascript(
        source: "localStorage.setItem('generationRequest', '$escapedJson');",
      );

      debugPrint('[Flutter] Stored generation request in localStorage');
    } catch (e) {
      debugPrint('[Flutter] Error storing generation request: $e');
    }
  }

  void _registerHandlers(InAppWebViewController controller) {
    // Handler: Vue is ready to show content
    controller.addJavaScriptHandler(
      handlerName: 'generationViewReady',
      callback: (args) {
        debugPrint('Vue generation view ready');
        if (mounted) {
          setState(() {
            _isVueReady = true;
          });
        }
      },
    );

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
              // Clear any previous errors on success
              _error = null;
            });

            // Navigate to presentation detail page after a brief delay
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && _presentationId != null) {
                context.router.replaceAll([
                  MainWrapperRoute(
                    children: [
                      ProjectsRoute(
                        children: [
                          PresentationDetailRoute(presentationId: _presentationId!),
                        ],
                      ),
                    ],
                  ),
                ]);
              }
            });
          }
        } else {
          // Generation failed - set error and clear loading state
          final errorMessage = data['error'] as String? ?? 'Generation failed';
          debugPrint('Generation error: $errorMessage');
          if (mounted) {
            setState(() {
              _error = errorMessage;
              _isVueReady =
                  false; // Reset Vue ready state so error view shows properly
            });
          }
        }
      },
    );
  }

  /// Navigate to Projects page after generation complete
  void _navigateToProjects() {
    // Pop all routes and navigate to MainWrapper with Projects tab active
    context.router.replaceAll([
      MainWrapperRoute(children: [const ProjectsRoute()]),
    ]);
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
