import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/const/resource.dart';
import 'package:AIPrimary/core/config/config.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/core/secure_storage/secure_storage_pod.dart';
import 'package:AIPrimary/features/generate/states/controller_provider.dart';
import 'package:AIPrimary/features/projects/data/dto/create_mindmap_request_dto.dart';
import 'package:AIPrimary/features/projects/data/source/projects_remote_source_provider.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/widgets/authenticated_webview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page that embeds the React app's /mindmap/embed/:id?mode=generate route
/// for AI-powered mindmap generation.
///
/// Flow:
/// 1. Creates empty mindmap via API
/// 2. Opens WebView with generation mode
/// 3. Stores generation request in localStorage
/// 4. Waits for React to signal 'mindmapGenerationViewReady'
/// 5. Shows WebView with React's generation UI
/// 6. React calls generate API, converts to nodes, updates mindmap
/// 7. React signals 'mindmapGenerationCompleted'
@RoutePage()
class MindmapGenerationWebViewPage extends ConsumerStatefulWidget {
  const MindmapGenerationWebViewPage({super.key});

  @override
  ConsumerState<MindmapGenerationWebViewPage> createState() =>
      _MindmapGenerationWebViewPageState();
}

class _MindmapGenerationWebViewPageState
    extends ConsumerState<MindmapGenerationWebViewPage> {
  bool _isReactReady = false;
  bool _isGenerationComplete = false;
  bool _isLoading = false;
  String? _error;
  String? _mindmapId;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _initializeAndCreateMindmap();
  }

  Future<void> _initializeAndCreateMindmap() async {
    // Load access token first
    final secureStorage = ref.read(secureStoragePod);
    _accessToken = await secureStorage.read(key: R.ACCESS_TOKEN_KEY);
    debugPrint('[MindmapGeneration] Token loaded: ${_accessToken != null}');

    // Then create mindmap
    await _createMindmap();
  }

  /// Create an empty mindmap to get an ID for the WebView URL
  Future<void> _createMindmap() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final formState = ref.read(mindmapFormControllerProvider);

      // Create empty mindmap request
      final createRequest = CreateMindmapRequestDto(
        title: formState.topic.isEmpty
            ? ref.read(translationsPod).projects.mindmaps.title
            : formState.topic,
        description: '',
        nodes: [],
        edges: [],
      );

      // Create mindmap via API
      // Error handling is centralized in DefaultAPIInterceptor
      final remoteSource = ref.read(projectsRemoteSourceProvider);
      final response = await remoteSource.createMindmap(createRequest);

      if (!mounted) return;

      setState(() {
        _mindmapId = response.data?.id;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error creating mindmap: $e');
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

    // Check platform support
    if (InAppWebViewPlatform.instance == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.projects.mindmaps.generateMindmap)),
        body: Center(
          child: Text(
            t.projects.mindmaps.webViewNotSupported,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // Show error if mindmap creation failed
    if (_error != null) {
      return _buildErrorView(t);
    }

    // Show loading while waiting for mindmap ID
    if (_isLoading || _mindmapId == null) {
      return _buildLoadingScaffold(t);
    }

    // Build WebView once we have the ID
    final locale = t.$meta.locale.languageCode;
    final tokenParam = _accessToken != null ? '&token=$_accessToken' : '';
    final url =
        '${Config.mindmapBaseUrl}/mindmap/embed/$_mindmapId?mode=generate&locale=$locale$tokenParam';

    if (kDebugMode) {
      debugPrint('Opening mindmap generation webview: $url');
    }

    return _buildWebViewScaffold(url, t);
  }

  Widget _buildLoadingScaffold(dynamic t) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.projects.mindmaps.generateMindmap),
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
            Text(t.projects.mindmaps.creatingMindmap),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(dynamic t) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.common.error),
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
                t.projects.mindmaps.failedToCreate,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? t.common.somethingWentWrong,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                  _createMindmap();
                },
                child: Text(t.common.retry),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.router.pop(),
                child: Text(t.common.goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebViewScaffold(String? url, dynamic t) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isGenerationComplete
              ? t.projects.mindmaps.title
              : t.projects.mindmaps.generatingMindmap,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () =>
              _isGenerationComplete ? _navigateToProjects() : _handleClose(),
        ),
      ),
      body: Stack(
        children: [
          // WebView - use Offstage instead of Opacity to prevent rendering when hidden
          if (url != null)
            Offstage(
              offstage: !_isReactReady,
              child: AuthenticatedWebView(
                webViewUrl: url,
                enableZoom: false,
                onWebViewCreated: (controller) {
                  _registerHandlers(controller);
                },
                onLoadStop: (controller, url) async {
                  debugPrint('WebView page loaded');
                  // Store generation request in localStorage for React to access
                  await _storeGenerationRequest(controller);
                },
                onReceivedError: (controller, request, error) {
                  debugPrint('WebView error: ${error.description}');
                },
                onConsoleMessage: (controller, message) {
                  debugPrint('[MindmapGeneration] ${message.message}');
                },
              ),
            ),

          // Single loading indicator - shown until React is ready
          if (!_isReactReady)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(t.projects.mindmaps.startingGeneration),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _registerHandlers(InAppWebViewController controller) {
    // Handler: React is ready to show content
    controller.addJavaScriptHandler(
      handlerName: 'mindmapGenerationViewReady',
      callback: (args) {
        debugPrint('React mindmap generation view ready');
        if (mounted) {
          setState(() {
            _isReactReady = true;
          });
        }
      },
    );

    // Handler: Generation completed (from React after processing)
    controller.addJavaScriptHandler(
      handlerName: 'mindmapGenerationCompleted',
      callback: (args) {
        final data = args.isNotEmpty ? args[0] as Map<String, dynamic> : {};
        debugPrint('Mindmap generation completed: $data');

        if (data['success'] == true) {
          final nodeCount = data['nodeCount'] as int?;
          debugPrint('Successfully generated mindmap with $nodeCount nodes');
          if (mounted) {
            setState(() {
              _isGenerationComplete = true;
              // Clear any previous errors on success
              _error = null;
            });
          }
        } else {
          // Generation failed - set error and clear loading state
          final errorMessage =
              data['error'] as String? ??
              ref.read(translationsPod).common.somethingWentWrong;
          debugPrint('Generation error: $errorMessage');
          if (mounted) {
            setState(() {
              _error = errorMessage;
              _isReactReady =
                  false; // Reset React ready state so error view shows properly
            });
          }
        }
      },
    );
  }

  /// Store generation request in localStorage for React to access
  Future<void> _storeGenerationRequest(
    InAppWebViewController controller,
  ) async {
    try {
      final formState = ref.read(mindmapFormControllerProvider);

      // Build request body matching MindmapMobileGenerationRequest
      final requestBody = {
        'mindmapId': _mindmapId,
        'topic': formState.topic,
        'model': formState.selectedModel?.name ?? '',
        'provider': formState.selectedModel?.provider ?? '',
        'language':
            formState.language.toLowerCase() == 'vietnamese' ||
                formState.language.toLowerCase() == 'vi'
            ? 'vi'
            : 'en',
        'maxDepth': formState.maxDepth,
        'maxBranchesPerNode': formState.maxBranchesPerNode,
        if (formState.grade != null) 'grade': formState.grade,
        if (formState.subject != null) 'subject': formState.subject,
      };

      final jsonString = jsonEncode(requestBody);

      // Escape for JavaScript
      final escapedJson = jsonString
          .replaceAll('\\', '\\\\')
          .replaceAll("'", "\\'")
          .replaceAll('\n', '\\n')
          .replaceAll('\r', '\\r');

      await controller.evaluateJavascript(
        source:
            "localStorage.setItem('mindmapGenerationRequest', '$escapedJson');",
      );

      debugPrint('[Flutter] Stored mindmap generation request in localStorage');
    } catch (e) {
      debugPrint('[Flutter] Error storing generation request: $e');
    }
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
        title: Text(t.projects.mindmaps.cancelGenerationDialog.title),
        content: Text(t.projects.mindmaps.cancelGenerationDialog.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.projects.mindmaps.cancelGenerationDialog.continue_),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.router.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t.projects.mindmaps.cancelGenerationDialog.cancel),
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
