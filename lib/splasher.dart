import 'package:datn_mobile/core/services/notification/notification_service.dart';
import 'package:datn_mobile/features/auth/controllers/user_controller.dart';
import 'package:datn_mobile/features/notification/service/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:datn_mobile/app/view/app.dart';
import 'package:datn_mobile/bootstrap.dart';
import 'package:datn_mobile/features/splash/view/splash_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Splasher extends ConsumerStatefulWidget {
  const Splasher({super.key});

  @override
  ConsumerState<Splasher> createState() => _SplasherState();
}

class _SplasherState extends ConsumerState<Splasher> {
  bool _hasRegisteredToken = false;

  @override
  void initState() {
    super.initState();
    _setupFcmTokenCallback();
  }

  void _setupFcmTokenCallback() {
    // Set up callback for FCM token refresh
    NotificationService().setOnTokenReceived((token) async {
      try {
        final apiService = ref.read(notificationApiServiceProvider);
        await apiService.registerDevice(token);
        debugPrint('FCM token registered on refresh: $token');
      } catch (e) {
        debugPrint('Failed to register FCM token on refresh: $e');
      }
    });
  }

  Future<void> _registerExistingToken() async {
    if (_hasRegisteredToken) return;
    _hasRegisteredToken = true;

    try {
      final token = await NotificationService().getToken();
      if (token != null) {
        final apiService = ref.read(notificationApiServiceProvider);
        await apiService.registerDevice(token);
        debugPrint('FCM token registered for existing session');
      }
    } catch (e) {
      debugPrint('Failed to register FCM token for existing session: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trigger get me for init userState
    final userState = ref.watch(userControllerProvider);

    // Register FCM token if user is authenticated
    userState.whenData((user) {
      if (user != null && !_hasRegisteredToken) {
        _registerExistingToken();
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.blue),
      home: SplashView(
        removeSplashLoader: false,
        onInitialized: (container) {
          bootstrap(() => const App(), parent: container);
        },
      ),
    );
  }
}
