import 'package:datn_mobile/core/router/router_pod.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/auth/data/dto/request/credential_signup_request.dart';
import 'package:datn_mobile/features/auth/domain/services/auth_service.dart';
import 'package:datn_mobile/features/auth/service/service_provider.dart';
import 'package:datn_mobile/features/auth/controllers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends AsyncNotifier<AuthState> {
  AuthState get currentState => state.value!;

  late final AuthService _authService;

  @override
  Future<AuthState> build() async {
    // Initialize the auth service
    _authService = ref.watch(authServiceProvider);
    // Initial state
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
      // On error
      state = AsyncValue.error(
        AuthState(errorMessage: e.toString()),
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
    required String phoneNumber,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Simulate sign-up logic
      _authService.signUp(
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

  // TODO: handle sign in with Google
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithGoogle();
      state = AsyncValue.data(AuthState(isAuthenticated: true));
    } catch (e) {
      state = AsyncValue.error(
        AuthState(errorMessage: e.toString()),
        StackTrace.current,
      );
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
    } catch (e) {
      state = AsyncValue.error(
        AuthState(errorMessage: e.toString()),
        StackTrace.current,
      );
    } finally {
      // Ensure state is reset to unauthenticated
      state = AsyncValue.data(AuthState(isAuthenticated: false));

      // Navigate to sign-in after logout
      final router = ref.read(autorouterProvider);
      await router.replace(const SignInRoute());
    }
  }
}
