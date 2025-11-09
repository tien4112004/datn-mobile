import 'dart:developer';

import 'package:datn_mobile/const/app_urls.dart';
import 'package:datn_mobile/core/secure_storage/secure_storage.dart';
import 'package:datn_mobile/features/auth/data/dto/request/credential_signin_request.dart';
import 'package:datn_mobile/features/auth/data/dto/request/token_exchange_request.dart';
import 'package:datn_mobile/features/auth/data/sources/auth_remote_source.dart';
import 'package:datn_mobile/features/auth/domain/services/auth_service.dart';
import 'package:datn_mobile/shared/exception/base_exception.dart';
import 'package:datn_mobile/shared/helper/url_launcher_util.dart';

class AuthServiceImpl implements AuthService {
  final AuthRemoteSource authRemoteSource;
  final SecureStorage secureStorage;

  AuthServiceImpl(this.authRemoteSource, this.secureStorage);

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final response = await authRemoteSource.signIn(
      CredentialSigninRequest(username: email, password: password),
    );

    if (response is APIException) {
      throw response;
    }

    await secureStorage.write(key: 'access_token', value: response.accessToken);
    await secureStorage.write(
      key: 'refresh_token',
      value: response.refreshToken,
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    final String uriWithPrefix = await authRemoteSource.getGoogleSignInUrl(
      AppUrls.googleRedirectUri,
    );

    final uri = uriWithPrefix.split("redirect:")[1];
    UrlLauncherUtil.launchExternalUrl(uri);
  }

  @override
  Future<void> handleGoogleSignInCallback(Uri uri) async {
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];

    if (code == null || state == null) {
      throw APIException(
        code: 400,
        errorMessage: 'Invalid callback URI: missing code or state',
      );
    }

    log('Received auth code: $code and state: $state');

    final response = await authRemoteSource.handleGoogleSignInCallback(
      TokenExchangeRequest(
        code: code,
        redirectUri: AppUrls.googleRedirectUri,
        state: state,
      ),
    );

    if (response is APIException) {
      throw response;
    }

    await secureStorage.write(key: 'access_token', value: response.accessToken);
    await secureStorage.write(
      key: 'refresh_token',
      value: response.refreshToken,
    );
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
