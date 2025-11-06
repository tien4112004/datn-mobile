import 'dart:developer';

import 'package:datn_mobile/features/auth/data/dto/token_exchange_request.dart';
import 'package:datn_mobile/features/auth/data/sources/auth_remote_source.dart';
import 'package:datn_mobile/features/auth/domain/services/auth_service.dart';
import 'package:datn_mobile/shared/helper/url_launcher_util.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthServiceImpl implements AuthService {
  final AuthRemoteSource authRemoteSource;

  AuthServiceImpl(this.authRemoteSource);

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    // TODO: implement signInWithEmailAndPassword
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithGoogle() async {
    final String uriWithPrefix = await authRemoteSource.getGoogleSignInUrl(
      'datnmobile://auth-callback',
    );

    final uri = uriWithPrefix.split("redirect:")[1];
    log('Launching Google Sign-In URL: $uri');

    UrlLauncherUtil.launchExternalUrl(uri);
  }

  @override
  Future<void> handleGoogleSignInCallback(Uri uri) async {
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];

    if (code == null || state == null) {
      log('Invalid callback URI: missing code or state');
      return;
    }

    log('Received auth code: $code and state: $state');

    await authRemoteSource.handleGoogleSignInCallback(
      TokenExchangeRequest(
        code: code,
        redirectUri: 'datnmobile://auth-callback',
        state: state,
      ),
    );

    log('Successfully handled Google Sign-In callback');
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    // TODO: implement signUpWithEmailAndPassword
    throw UnimplementedError();
  }
}
