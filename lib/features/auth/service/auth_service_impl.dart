import 'dart:developer';

import 'package:datn_mobile/const/app_urls.dart';
import 'package:datn_mobile/const/resource.dart';
import 'package:datn_mobile/core/secure_storage/secure_storage.dart';
import 'package:datn_mobile/features/auth/data/dto/request/credential_signin_request.dart';
import 'package:datn_mobile/features/auth/data/dto/request/credential_signup_request.dart';
import 'package:datn_mobile/features/auth/data/dto/request/token_exchange_request.dart';
import 'package:datn_mobile/features/auth/data/sources/auth_remote_source.dart';
import 'package:datn_mobile/features/auth/domain/services/auth_service.dart';
import 'package:datn_mobile/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:datn_mobile/shared/exception/base_exception.dart';
import 'package:datn_mobile/shared/exception/unexpected_exception.dart';
import 'package:datn_mobile/shared/helper/url_launcher_util.dart';
import 'package:flutter/foundation.dart';

class AuthServiceImpl implements AuthService {
  final AuthRemoteSource authRemoteSource;
  final SecureStorage secureStorage;

  AuthServiceImpl(this.authRemoteSource, this.secureStorage);
  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await authRemoteSource.signIn(
        CredentialSigninRequest(email: email, password: password),
      );

      // Validate and extract token response using the helper
      final tokenResponse = response.validateAndExtractData('sign-in');

      // Store tokens with error handling
      try {
        await secureStorage.write(
          key: R.ACCESS_TOKEN_KEY,
          value: tokenResponse.accessToken,
        );
        await secureStorage.write(
          key: R.REFRESH_TOKEN_KEY,
          value: tokenResponse.refreshToken,
        );
      } catch (e) {
        throw APIException(
          code: 500,
          errorMessage: 'Failed to store authentication tokens',
          errorCode: 'STORAGE_ERROR',
        );
      }
    } catch (e) {
      if (e is APIException) {
        rethrow;
      }
      // Wrap unexpected errors
      throw APIException(
        code: 500,
        errorMessage: 'Unexpected error during sign-in: ${e.toString()}',
        errorCode: 'SIGNIN_ERROR',
      );
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    final response = await authRemoteSource.getGoogleSignInUrl(
      AppUrls.googleRedirectUri,
    );

    final uri = response.split("redirect:")[1];

    // if (kDebugMode) {
    log('Received Google Sign-In URL: $response');
    log('Launching Google Sign-In URL: $uri');
    // }

    UrlLauncherUtil.launchExternalUrl(uri);
  }

  @override
  Future<void> handleGoogleSignInCallback(Uri uri) async {
    try {
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];

      if (code == null || state == null) {
        throw APIException(
          code: 400,
          errorMessage: 'Invalid callback URI: missing code or state',
          errorCode: 'INVALID_CALLBACK',
        );
      }

      if (kDebugMode) {
        log('Received auth code: $code and state: $state');
      }

      final response = await authRemoteSource.handleGoogleSignInCallback(
        TokenExchangeRequest(
          code: code,
          redirectUri: AppUrls.googleRedirectUri,
          state: state,
        ),
      );

      // Validate and extract token response using the helper
      final tokenResponse = response.validateAndExtractData(
        'google-sign-in-callback',
      );

      // Store tokens with error handling
      try {
        await secureStorage.write(
          key: R.ACCESS_TOKEN_KEY,
          value: tokenResponse.accessToken,
        );
        await secureStorage.write(
          key: R.REFRESH_TOKEN_KEY,
          value: tokenResponse.refreshToken,
        );
      } catch (e) {
        throw APIException(
          code: 500,
          errorMessage: 'Failed to store authentication tokens',
          errorCode: 'STORAGE_ERROR',
        );
      }
    } catch (e) {
      if (e is APIException) {
        rethrow;
      }
      // Wrap unexpected errors
      throw APIException(
        code: 500,
        errorMessage: 'Unexpected error during Google sign-in: ${e.toString()}',
        errorCode: 'GOOGLE_SIGNIN_ERROR',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Delete local tokens first
      await secureStorage.delete(key: R.ACCESS_TOKEN_KEY);
      await secureStorage.delete(key: R.REFRESH_TOKEN_KEY);

      // Call remote logout
      final response = await authRemoteSource.logout();

      // Validate response
      if (!response.success) {
        throw APIException(
          code: response.code,
          errorCode: response.errorCode,
          errorMessage: response.detail ?? 'Logout failed',
        );
      }

      if (kDebugMode) {
        log('Sign-out successful');
      }
    } catch (e) {
      if (e is APIException) {
        rethrow;
      }
      // Wrap unexpected errors
      throw UnexpectedException(
        errorCode: 'SIGNOUT_ERROR',
        httpCode: 500,
        errorMessage: 'Unexpected error during sign-out: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    // TODO: implement signUpWithEmailAndPassword
    throw UnimplementedError();
  }

  @override
  Future<void> signUp(CredentialSignupRequest request) async {
    try {
      final response = await authRemoteSource.signup(request);

      // Validate and extract user profile response
      final userProfile = response.validateAndExtractData('sign-up');

      if (kDebugMode) {
        log('Sign-up successful for user: ${userProfile.email}');
      }
    } catch (e) {
      if (e is APIException) {
        rethrow;
      }
      // Wrap unexpected errors
      throw APIException(
        code: 500,
        errorMessage: 'Unexpected error during sign-up: ${e.toString()}',
        errorCode: 'SIGNUP_ERROR',
      );
    }
  }
}
