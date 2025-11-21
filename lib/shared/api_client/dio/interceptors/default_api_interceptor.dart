import 'package:dio/dio.dart';
import 'package:datn_mobile/shared/api_client/dio/default_api_error_handler.dart';
import 'package:flutter/foundation.dart';

// coverage:ignore-file

///This one is default interceptor which includes default api
///error handler and adds platform-specific headers
class DefaultAPIInterceptor extends Interceptor {
  DefaultAPIInterceptor({required this.dio});
  final Dio dio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Log headers in debug mode
    debugPrint('Request Headers: ${options.headers}');
    debugPrint('Request URL: ${options.uri}');

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    defaultAPIErrorHandler(err, handler, dio);
  }
}
