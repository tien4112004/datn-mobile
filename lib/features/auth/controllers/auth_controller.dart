import 'dart:developer';

import 'package:datn_mobile/features/auth/data/dto/request/credential_signup_request.dart';
import 'package:datn_mobile/features/auth/domain/services/auth_service.dart';
import 'package:datn_mobile/features/auth/service/service_provider.dart';
import 'package:datn_mobile/features/auth/controllers/auth_state.dart';
import 'package:datn_mobile/shared/exception/base_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends AsyncNotifier<AuthState> {
  AuthState get currentState => state.value!;

  late final AuthService _authService;

  @override
  Future<AuthState> build() async {
    // Initialize the auth service
    _authService = ref.watch(authServiceProvider);

    // Initial state
    state = AsyncValue.data(AuthState(isAuthenticated: false));

    return AuthState();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      // Simulate sign-in logic
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // On success
      state = AsyncValue.data(AuthState(isAuthenticated: true));
    } catch (e) {
      log('Error during sign-in: $e');
      // On error
      if (e is APIException) {
        log('APIException caught: ${e.errorMessage}');
        state = AsyncValue.error(
          AuthState(errorMessage: e.errorMessage),
          StackTrace.current,
        );
        return;
      }

      state = AsyncValue.error(
        AuthState(errorMessage: 'An unexpected error occurred during sign-in.'),
        StackTrace.current,
      );
    }
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
    try {
      // Simulate sign-up logic
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
      // On success
      state = AsyncValue.data(AuthState(isAuthenticated: true));
    } catch (e) {
      // On error
      state = AsyncValue.error(
        AuthState(errorMessage: e.toString()),
        StackTrace.current,
      );
    }
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
          errorMessage: 'An unexpected error occurred during google sign-in.',
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
