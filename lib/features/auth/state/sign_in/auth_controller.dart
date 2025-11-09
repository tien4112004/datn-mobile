import 'package:datn_mobile/core/router/router_pod.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/auth/domain/services/auth_service.dart';
import 'package:datn_mobile/features/auth/service/service_provider.dart';
import 'package:datn_mobile/features/auth/state/auth_state.dart';
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

      // Navigate to home after successful sign-in and token storage
      // Get the router from ref
      final router = ref.read(autorouterProvider);
      await router.replace(const HomeRoute());
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

      // Navigate to home after successful Google sign-in
      final router = ref.read(autorouterProvider);
      await router.replace(const HomeRoute());
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
      state = AsyncValue.data(AuthState(isAuthenticated: false));

      // Navigate to sign-in after logout
      final router = ref.read(autorouterProvider);
      await router.replace(const SignInRoute());
    } catch (e) {
      state = AsyncValue.error(
        AuthState(errorMessage: e.toString()),
        StackTrace.current,
      );
    }
  }
}
