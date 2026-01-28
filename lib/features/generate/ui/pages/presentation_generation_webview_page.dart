import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/config/config.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/projects/data/dto/presentation_dto.dart';
import 'package:datn_mobile/features/projects/data/source/projects_remote_source_provider.dart';
import 'package:datn_mobile/shared/helper/date_format_helper.dart';
import 'package:datn_mobile/shared/widgets/authenticated_webview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page that embeds the Vue app's /generation/:id route for real-time presentation generation
///
/// This page follows the same pattern as MobileApp.vue:
/// 1. Creates presentation via API first (gets back presentationId)
/// 2. Stores generation request in localStorage
/// 3. Opens webview with /generation/:id
/// 4. Vue fetches presentation and generation request, then starts streaming
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
  bool _isWebViewLoading = true;
  bool _isCreatingPresentation = true;
  bool _isPageLoaded = false;
  bool _isVueReady = false;
  bool _hasStoredData = false;
  String? _error;
  String? _presentationId;

  static const String _generationRequestStorageKey = 'generation_request';

  @override
  void initState() {
    super.initState();
    _createPresentation();
  }

  Future<void> _createPresentation() async {
    try {
      final formState = ref.read(presentationFormControllerProvider);

      // Create presentation DTO with initial data
      final presentationDto = PresentationDto(
        id: '', // Will be assigned by backend
        title: formState.topic.isEmpty
            ? 'Untitled Presentation'
            : formState.topic,
        metaData: {},
        slides: [],
        createdAt: DateFormatHelper.getNow(),
        updatedAt: DateFormatHelper.getNow(),
        isParsed: false,
        viewport: {'width': 1000.0, 'height': 562.5},
      );

      // Create presentation via API
      final remoteSource = ref.read(projectsRemoteSourceProvider);
      final createdPresentation = await remoteSource.createPresentation(
        presentationDto,
      );

      if (mounted) {
        setState(() {
          _presentationId = createdPresentation.id;
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
    // Check platform support
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
        title: const Text('Generating Presentation'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleClose(),
        ),
      ),
      body: Stack(
        children: [
          AuthenticatedWebView(
            webViewUrl: url,
            enableZoom: false,
            onWebViewCreated: (controller) {
              _webViewController = controller;
              _registerHandlers(controller);
            },
            onLoadStop: (controller, url) async {
              debugPrint('WebView page loaded');
              _isPageLoaded = true;
              setState(() => _isWebViewLoading = false);
              // Try to start generation if Vue is ready
              _tryStartGeneration();
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

  /// Try to start the generation process
  /// This is called when both page is loaded and Vue is ready
  void _tryStartGeneration() {
    if (_isPageLoaded &&
        _isVueReady &&
        !_hasStoredData &&
        _webViewController != null) {
      _hasStoredData = true;
      _storeGenerationRequest(_webViewController!);
    }
  }

  Future<void> _storeGenerationRequest(
    InAppWebViewController controller,
  ) async {
    if (_presentationId == null) return;

    final formController = ref.read(
      presentationFormControllerProvider.notifier,
    );

    // Build the generation request
    final generationRequest = formController.toPresentationRequest();

    // Convert to JSON for Vue's PresentationGenerationRequest format
    final requestJson = {
      'model': {
        'name': generationRequest.model,
        'provider': generationRequest.provider,
      },
      'language': generationRequest.language,
      'slideCount': generationRequest.slideCount,
      'outline': generationRequest.outline,
      'presentation': generationRequest.presentation,
      'others': generationRequest.others,
    };

    try {
      // Store in localStorage with presentation ID as key
      final storageKey = '${_generationRequestStorageKey}_$_presentationId';
      final jsonString = jsonEncode(
        requestJson,
      ).replaceAll("'", "\\'").replaceAll('\n', '\\n');
      await controller.evaluateJavascript(
        source:
            '''
          localStorage.setItem('$storageKey', '$jsonString');
        ''',
      );
      debugPrint('Generation request stored in localStorage');

      // Notify Vue to start the generation process
      await controller.evaluateJavascript(
        source: '''
          if (window.startGeneration) {
            window.startGeneration();
          } else {
            console.error('startGeneration not available');
          }
        ''',
      );
      debugPrint('Called startGeneration on Vue app');
    } catch (e) {
      debugPrint('Error storing generation request: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to initialize generation';
        });
      }
    }
  }

  void _registerHandlers(InAppWebViewController controller) {
    // Handler: Vue app view is ready
    controller.addJavaScriptHandler(
      handlerName: 'generationViewReady',
      callback: (args) {
        debugPrint('Generation view ready');
        _isVueReady = true;
        // Try to start generation if page is loaded
        _tryStartGeneration();
      },
    );

    // Handler: Generation has started
    controller.addJavaScriptHandler(
      handlerName: 'generationStarted',
      callback: (args) {
        final data = args.isNotEmpty ? args[0] as Map<String, dynamic> : {};
        debugPrint('Generation started: $data');

        if (data['success'] != true) {
          if (mounted) {
            setState(() {
              _error = data['error'] as String? ?? 'Failed to start generation';
            });
          }
        }
      },
    );

    // Handler: Generation completed
    controller.addJavaScriptHandler(
      handlerName: 'generationCompleted',
      callback: (args) {
        final data = args.isNotEmpty ? args[0] as Map<String, dynamic> : {};
        debugPrint('Generation completed: $data');

        if (data['success'] == true) {
          final slideCount = data['slideCount'] as int?;
          debugPrint('Successfully generated $slideCount slides');
          _navigateToDetail();
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

  void _navigateToDetail() {
    if (!mounted || _presentationId == null) return;

    context.router.popUntilRouteWithName(MainWrapperRoute.name);
    context.router.push(
      PresentationDetailRoute(presentationId: _presentationId!),
    );
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
