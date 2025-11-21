import 'package:datn_mobile/features/auth/data/dto/request/credential_signup_request.dart';

abstract class AuthService {
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signUp(CredentialSignupRequest request);

  Future<void> signInWithGoogle();

  Future<void> handleGoogleSignInCallback(Uri uri);

  Future<void> signOut();
}
