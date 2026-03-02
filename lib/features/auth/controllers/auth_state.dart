class AuthState {
  final bool isAuthenticated;
  final bool isSignedUp;
  final bool requiresPasswordChange;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.isSignedUp = false,
    this.requiresPasswordChange = false,
    this.errorMessage,
  });
}
