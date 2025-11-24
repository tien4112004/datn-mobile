class AuthState {
  final bool isAuthenticated;
  final bool isSignedUp;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.isSignedUp = false,
    this.errorMessage,
  });
}
