import 'dart:developer';

import 'package:datn_mobile/features/auth/data/dto/request/credential_signup_request.dart';
import 'package:datn_mobile/features/auth/domain/services/auth_service.dart';
import 'package:datn_mobile/features/auth/service/service_provider.dart';
import 'package:datn_mobile/features/auth/controllers/auth_state.dart';
import 'package:datn_mobile/shared/exception/base_exception.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends AsyncNotifier<AuthState> {
  late final AuthService _authService;

  @override
  Future<AuthState> build() async {
    // Initialize the auth service
    _authService = ref.watch(authServicePod);

    // Initial state
    final initialState = AuthState(isAuthenticated: false);
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
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithGoogle();
      state = AsyncValue.data(AuthState(isAuthenticated: true));
    } catch (e) {
      log('Error during google sign-in: $e');
      if (e is APIException) {
        state = AsyncValue.error(
          AuthState(errorMessage: e.errorMessage),
          StackTrace.current,
        );
        return;
      }
      state = AsyncValue.error(
        AuthState(
          errorMessage: ref.read(translationsPod).auth.signIn.googleSignInError,
        ),
        StackTrace.current,
      );
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      state = AsyncValue.data(AuthState(isAuthenticated: false));
    } catch (e) {
      state = AsyncValue.error(
        AuthState(errorMessage: e.toString()),
        StackTrace.current,
      );
    }
  }
}
