import 'package:datn_mobile/features/auth/domain/services/auth_service.dart';
import 'package:datn_mobile/features/auth/service/service_provider.dart';
import 'package:datn_mobile/features/auth/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupController extends AsyncNotifier<AuthState> {
  AuthState get currentState => state.value!;

  late final AuthService _authService;

  SignupController() {
    _authService = ref.read(authServiceProvider);
  }

  @override
  Future<AuthState> build() async {
    // Initial state
    return AuthState();
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      // Simulate sign-up logic
      await _authService.signUpWithEmailAndPassword(
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
}
