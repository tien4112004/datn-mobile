import 'package:AIPrimary/core/services/notification/notification_service.dart';
import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/notification/domain/entity/notification_type.dart';
import 'package:AIPrimary/features/notification/service/service_provider.dart';
import 'package:AIPrimary/features/projects/states/controller_provider.dart';
import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:flutter/material.dart';
import 'package:AIPrimary/app/view/app.dart';
import 'package:AIPrimary/bootstrap.dart';
import 'package:AIPrimary/features/splash/view/splash_view.dart';
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
    NotificationService().setOnMessageReceived((message) {
      final typeString = message.data['type'] as String?;
      if (typeString == null) return;
      try {
        final type = NotificationType.fromString(typeString);
        debugPrint('Notification type: $type');
        if (type == NotificationType.sharedPresentation ||
            type == NotificationType.sharedMindmap) {
          debugPrint('Shared resource notification received');
          ref.read(sharedResourcesControllerProvider.notifier).refresh();
        }
      } catch (_) {
        // Unknown type - ignore
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
      }
    } catch (_) {
      // Silent fail - token registration is not critical
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trigger get me for init userState
    final userState = ref.watch(userControllerPod);

    // Register FCM token if user is authenticated
    userState.whenData((user) {
      if (user != null && !_hasRegisteredToken) {
        _registerExistingToken();
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Themes.theme,
      home: SplashView(
        removeSplashLoader: false,
        onInitialized: (container) {
          bootstrap(() => const App(), parent: container);
        },
      ),
    );
  }
}
