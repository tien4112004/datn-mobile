import 'package:datn_mobile/const/resource.dart';
import 'package:datn_mobile/core/secure_storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
      debugPrint('Access token: $accessToken');

      final refreshToken = await secureStorage.read(key: R.REFRESH_TOKEN_KEY);
      debugPrint('Refresh token: $refreshToken');

      String cookies =
          '${R.ACCESS_TOKEN_KEY}=${accessToken ?? ''}; ${R.REFRESH_TOKEN_KEY}=${refreshToken ?? ''}';

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        options.headers['Cookie'] = cookies;
      } else {
        debugPrint('No access token found in secure storage');
      }
    } catch (e) {
      debugPrint('Error reading access token: $e');
    }

    debugPrint('Request Options: ${options.method} ${options.path}');
    debugPrint('Request Headers: ${options.headers}');

    handler.next(options);
  }
}
