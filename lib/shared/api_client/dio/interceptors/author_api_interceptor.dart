import 'dart:developer';

import 'package:datn_mobile/const/resource.dart';
import 'package:datn_mobile/core/secure_storage/secure_storage.dart';
import 'package:dio/dio.dart';

// coverage:ignore-file
///This one is author interceptor which includes default api
class AuthorAPIInterceptor extends Interceptor {
  AuthorAPIInterceptor({required this.dio, required this.secureStorage});

  final SecureStorage secureStorage;
  final Dio dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final accessToken = await secureStorage.read(key: R.ACCESS_TOKEN_KEY);

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        log('AccessToken in AuthorAPIInterceptor: $accessToken');
      } else {
        log('No access token found in secure storage');
      }
    } catch (e) {
      log('Error reading access token: $e');
    }

    handler.next(options);
  }
}
