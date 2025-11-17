import 'dart:io';
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
    // Add platform-specific headers to identify mobile app
    options.headers.addAll({
      'User-Agent': 'DatnMobile/1.0.0 (${Platform.operatingSystem})',
      'X-App-Platform': Platform.isAndroid
          ? 'android'
          : Platform.isIOS
          ? 'ios'
          : Platform.operatingSystem,
      'X-App-Version': '1.0.0',
      'X-Requested-With': 'com.example.datn_mobile', // Your package name
    });

    // Log headers in debug mode
    if (kDebugMode) {
      print('Request Headers: ${options.headers}');
      print('Request URL: ${options.uri}');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    defaultAPIErrorHandler(err, handler, dio);
  }
}
