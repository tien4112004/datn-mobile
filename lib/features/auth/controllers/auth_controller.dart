import 'package:datn_mobile/const/resource.dart';
import 'package:datn_mobile/core/local_storage/app_storage_pod.dart';
import 'package:datn_mobile/core/secure_storage/secure_storage_pod.dart';
import 'package:datn_mobile/core/services/notification/notification_service.dart';
import 'package:datn_mobile/features/auth/controllers/user_controller.dart';
import 'package:datn_mobile/features/auth/data/dto/request/credential_signup_request.dart';
import 'package:datn_mobile/features/auth/domain/services/auth_service.dart';
import 'package:datn_mobile/features/auth/service/service_provider.dart';
import 'package:datn_mobile/features/auth/controllers/auth_state.dart';
import 'package:datn_mobile/features/notification/service/service_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends AsyncNotifier<AuthState> {
  late final AuthService _authService;

  @override
  Future<AuthState> build() async {
    // Initialize the auth service
    _authService = ref.watch(authServicePod);

    final isAuthenticated = await ref
        .read(secureStoragePod)
        .containsKey(R.ACCESS_TOKEN_KEY);

    // Initial state
    final initialState = AuthState(isAuthenticated: isAuthenticated);
    state = AsyncValue.data(initialState);

    return initialState;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch and store user profile after successful login
      await ref
          .read(userControllerProvider.notifier)
          .fetchAndStoreUserProfile();

      // Register FCM token with backend
      await _registerFcmToken();

      return AuthState(isAuthenticated: true);
    });
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required DateTime dateOfBirth,
    String? phoneNumber,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.signUp(
        CredentialSignupRequest(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          phoneNumber: phoneNumber,
          dateOfBirth: DateTime(
            dateOfBirth.year,
            dateOfBirth.month,
            dateOfBirth.day,
          ),
        ),
      );
      return AuthState(isSignedUp: true);
    });
  }

  Future<void> signInWithGoogle() async {
    await _authService.signInWithGoogle();
  }

  Future<void> handleGoogleCallback(Uri uri) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.handleGoogleSignInCallback(uri);

      // Fetch and store user profile after successful login
      await ref
          .read(userControllerProvider.notifier)
          .fetchAndStoreUserProfile();

      // Register FCM token with backend
      await _registerFcmToken();

      return AuthState(isAuthenticated: true);
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.signOut();

      // Clear user profile from storage
      await _clearUserProfile();

      return AuthState(isAuthenticated: false);
    });
  }

  /// Clear user profile from local storage
  Future<void> _clearUserProfile() async {
    try {
      final storage = ref.read(appStorageProvider);
      await storage.delete(key: R.USER_PROFILE_KEY);
    } catch (e) {
      // print('Failed to clear user profile from storage: $e');
    }
  }

  /// Register FCM device token with backend
  Future<void> _registerFcmToken() async {
    try {
      final notificationService = NotificationService();
      final token = await notificationService.getToken();
      if (token != null) {
        final apiService = ref.read(notificationApiServiceProvider);
        await apiService.registerDevice(token);
        debugPrint('FCM token registered with backend');
      }
    } catch (e) {
      debugPrint('Failed to register FCM token: $e');
    }
  }
}
