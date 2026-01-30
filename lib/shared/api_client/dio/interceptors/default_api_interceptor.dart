import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:dio/dio.dart';
import 'package:AIPrimary/shared/api_client/dio/default_api_error_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// coverage:ignore-file

///This one is default interceptor which includes default api
///error handler and adds platform-specific headers
class DefaultAPIInterceptor extends Interceptor {
  DefaultAPIInterceptor({required this.dio, required this.ref});
  final Dio dio;
  final Ref ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    defaultAPIErrorHandler(
      err,
      handler,
      dio,
      translations: ref.watch(translationsPod),
    );
  }
}
