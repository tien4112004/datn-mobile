// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:AIPrimary/features/auth/controllers/auth_controller_pod.dart';
import 'package:AIPrimary/shared/pods/loading_overlay_pod.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/core/router/auto_route_observer.dart';
import 'package:AIPrimary/core/router/router_pod.dart';
import 'package:AIPrimary/core/services/notification/notification_navigation_handler.dart';
import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/core/theme/theme_controller.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/helper/global_helper.dart';
import 'package:AIPrimary/shared/widgets/no_internet_widget.dart';
import 'package:AIPrimary/shared/widgets/responsive_wrapper.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

///This class holds Material App or Cupertino App
///with routing,theming and locale setup .
///Also responsive framerwork used for responsive application
///which auto resize or autoscale the app.
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with GlobalHelper {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();

    // Register router for notification navigation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(autorouterProvider);
      NotificationNavigationHandler.registerRouter(router);
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    NotificationNavigationHandler.unregisterRouter();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleAuthCallback(uri);
    });
  }

  Future<void> _handleAuthCallback(Uri uri) async {
    debugPrint('Handling auth callback: $uri');
    if (uri.host == 'auth-callback') {
      try {
        await ref.read(authControllerPod.notifier).handleGoogleCallback(uri);
      } on Exception catch (e, stack) {
        log('Error handling auth callback: $e', stackTrace: stack);
        showErrorSnack(
          child: const Text('Error during authentication callback.'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final approuter = ref.watch(autorouterProvider);
    final currentTheme = ref.watch(themeControllerProvider);
    final translations = ref.watch(translationsPod);
    final isLoading = ref.watch(loadingOverlayPod);
    debugPrint('Loading overlay state: $isLoading');

    // Global listener for auth state changes to manage loading overlay
    ref.listen(authControllerPod, (previous, next) {
      next.when(
        data: (state) {
          ref.read(loadingOverlayPod.notifier).state = false;
        },
        loading: () {
          ref.read(loadingOverlayPod.notifier).state = true;
        },
        error: (error, stackTrace) {
          ref.read(loadingOverlayPod.notifier).state = false;
        },
      );
    });

    return Stack(
      alignment: Alignment.center,
      children: [
        MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'AI Primary',
          theme: Themes.theme,
          darkTheme: Themes.darkTheme,
          themeMode: currentTheme,
          routerConfig: approuter.config(
            placeholder: (context) => const SizedBox.shrink(),
            navigatorObservers: () => [RouterObserver()],
          ),
          locale: translations.$meta.locale.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          builder: (context, child) {
            if (mounted) {
              child = ResponsiveBreakPointWrapper(
                firstFrameWidget: Container(color: Colors.white),
                child: child!,
              );

              final mediaquery = MediaQuery.of(context);
              child = MediaQuery(
                data: mediaquery.copyWith(
                  textScaler: TextScaler.linear(
                    mediaquery.textScaleFactor.clamp(0, 1),
                  ),
                ),
                child: child,
              );

              child = AnnotatedRegion<SystemUiOverlayStyle>(
                value: currentTheme == ThemeMode.dark
                    ? SystemUiOverlayStyle.light.copyWith(
                        statusBarColor: Colors.white.withValues(alpha: 0.4),
                        systemNavigationBarColor: Colors.black,
                        systemNavigationBarDividerColor: Colors.black,
                        systemNavigationBarIconBrightness: Brightness.dark,
                      )
                    : currentTheme == ThemeMode.light
                    ? SystemUiOverlayStyle.dark.copyWith(
                        statusBarColor: Colors.white.withValues(alpha: 0.4),
                        systemNavigationBarColor: Colors.white,
                        systemNavigationBarDividerColor: Colors.white,
                        systemNavigationBarIconBrightness: Brightness.dark,
                      )
                    : SystemUiOverlayStyle.dark.copyWith(
                        statusBarColor: Colors.white.withValues(alpha: 0.4),
                        systemNavigationBarColor: Colors.white,
                        systemNavigationBarDividerColor: Colors.white,
                        systemNavigationBarIconBrightness: Brightness.dark,
                      ),
                child: GestureDetector(
                  child: child,
                  onTap: () {
                    hideKeyboard();
                  },
                ),
              );
            } else {
              child = const SizedBox.shrink();
            }

            return Toast(
              navigatorKey: navigatorKey,
              child: child,
            ).monitorConnection();
          },
        ),

        if (isLoading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
