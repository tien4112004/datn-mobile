import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:dio/dio.dart';

// coverage:ignore-file
///This error handler used in interceptor for resolving response for specific
///dio exception type to generalize the mesages whic can easy to understand for the end user.
Future<void> defaultAPIErrorHandler(
  DioException err,
  ErrorInterceptorHandler handler,
  Dio dio,
) async {
  switch (err.type) {
    case DioExceptionType.connectionTimeout:
      handler.resolve(
        Response(
          data: {'detail': 'connect timeout error'},
          requestOptions: err.requestOptions,
        ),
      );
    case DioExceptionType.sendTimeout:
      handler.resolve(
        Response(
          data: {'detail': 'sending data is slow'},
          requestOptions: err.requestOptions,
        ),
      );
    case DioExceptionType.receiveTimeout:
      handler.resolve(
        Response(
          data: {'detail': 'receiving data is slow'},
          requestOptions: err.requestOptions,
        ),
      );
    case DioExceptionType.badResponse:
      final statusCode = err.response?.statusCode;
      final data = err.response?.data;
      String detail = 'unknown error';

      if (data is Map<String, dynamic>) {
        final errorCode = data['errorCode'];
        final message = data['message'];

        if (errorCode != null && errorCode is String) {
          try {
            final translated = t['errors.$errorCode'];
            if (translated is String) {
              detail = translated;
            } else {
              detail = message ?? errorCode;
            }
          } catch (_) {
            detail = message ?? errorCode;
          }
        } else {
          detail = message ?? 'unknown error';
        }
      }

      if (statusCode == 404) {
        detail = data is Map
            ? (data['message'] ?? 'resource not found')
            : 'resource not found';
      }

      handler.resolve(
        Response(
          data: {if (data is Map<String, dynamic>) ...data, 'detail': detail},
          requestOptions: err.requestOptions,
          statusCode: statusCode,
          statusMessage: err.response?.statusMessage,
        ),
      );
    case DioExceptionType.cancel:
      handler.resolve(
        Response(
          data: {'detail': 'user cancelled request'},
          requestOptions: err.requestOptions,
        ),
      );
    case DioExceptionType.badCertificate:
      handler.resolve(
        Response(
          data: {'detail': 'Bad certificate'},
          requestOptions: err.requestOptions,
        ),
      );
    case DioExceptionType.connectionError:
      handler.resolve(
        Response(
          data: {'detail': 'No Internet'},
          requestOptions: err.requestOptions,
        ),
      );
    case DioExceptionType.unknown:
      handler.resolve(
        Response(
          data: {'detail': 'other error data:${err.response?.data}'},
          requestOptions: err.requestOptions,
        ),
      );
  }
}
