abstract class AuthService {
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> handleGoogleSignInCallback(Uri uri);

  Future<void> signOut();
}
