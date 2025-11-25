import 'dart:developer';
import 'dart:io';

import 'package:datn_mobile/const/resource.dart';
import 'package:datn_mobile/core/config/config.dart';
import 'package:datn_mobile/core/secure_storage/secure_storage.dart';
import 'package:datn_mobile/features/auth/data/dto/request/credential_signin_request.dart';
import 'package:datn_mobile/features/auth/data/dto/request/credential_signup_request.dart';
import 'package:datn_mobile/features/auth/data/sources/auth_remote_source.dart';
import 'package:datn_mobile/features/auth/domain/services/auth_service.dart';
import 'package:datn_mobile/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:datn_mobile/shared/exception/base_exception.dart';
import 'package:datn_mobile/shared/exception/unexpected_exception.dart';
import 'package:datn_mobile/shared/helper/url_launcher_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthServiceImpl implements AuthService {
  // With other routes, we can use the Retrofit generated Dio instance
  // This dio is using for authorize route, which support automatically
  // follow redirect.
  final Dio dio;

  final AuthRemoteSource authRemoteSource;
  final SecureStorage secureStorage;

  AuthServiceImpl(this.authRemoteSource, this.secureStorage, this.dio);
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
        debugPrint('Sign-in error: ${e.errorMessage}');
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
    final httpResponse = await dio.get(
      '${Config.baseUrl}/auth/google/authorize',
      queryParameters: {'clientType': 'mobile'},
      options: Options(
        followRedirects: false,
        validateStatus: (status) {
          return status != null && status >= 200 && status < 400;
        },
      ),
    );

    if (httpResponse.statusCode != 302) {
      throw APIException(
        code: httpResponse.statusCode,
        errorMessage:
            'Failed to get Google Sign-In URL, unexpected status code',
        errorCode: 'GOOGLE_SIGNIN_URL_ERROR',
      );
    }

    final location = httpResponse.headers.value(HttpHeaders.locationHeader);

    if (location == null) {
      throw APIException(
        code: 500,
        errorMessage:
            'Failed to get Google Sign-In URL, missing Location header',
        errorCode: 'GOOGLE_SIGNIN_URL_MISSING',
      );
    }

    if (kDebugMode) {
      log('Received Google Sign-In URL: $location');
      log('Launching Google Sign-In URL: $location');
    }

    UrlLauncherUtil.launchExternalUrl(location);
  }

  @override
  Future<void> handleGoogleSignInCallback(Uri uri) async {
    try {
      debugPrint('Auth callback URI: $uri');
      debugPrint('Auth callback query parameters: ${uri.queryParameters}');

      final accessToken = uri.queryParameters['access_token'];
      final refreshToken = uri.queryParameters['refresh_token'];

      if (accessToken == null || refreshToken == null) {
        throw APIException(
          code: 400,
          errorMessage: 'Invalid callback URI: missing code or state',
          errorCode: 'INVALID_CALLBACK',
        );
      }

      debugPrint('Received auth code: $accessToken and state: $refreshToken');

      // Store tokens with error handling
      try {
        await secureStorage.write(key: R.ACCESS_TOKEN_KEY, value: accessToken);
        await secureStorage.write(
          key: R.REFRESH_TOKEN_KEY,
          value: refreshToken,
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
      // Call remote logout
      final response = await dio.post('${Config.baseUrl}/auth/logout');

      if (response.statusCode != HttpStatus.noContent) {
        throw APIException(
          code: response.statusCode ?? 500,
          errorMessage: 'Failed to logout from server, unexpected status code',
          errorCode: 'LOGOUT_ERROR',
        );
      }

      debugPrint('Sign-out successful');

      // Delete local tokens only if remote logout is successful
      await secureStorage.delete(key: R.ACCESS_TOKEN_KEY);
      await secureStorage.delete(key: R.REFRESH_TOKEN_KEY);
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
