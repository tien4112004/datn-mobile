import 'package:datn_mobile/core/config/config.dart';
import 'package:datn_mobile/core/secure_storage/secure_storage.dart';
import 'package:datn_mobile/core/secure_storage/secure_storage_pod.dart';
import 'package:datn_mobile/shared/api_client/dio/interceptors/author_api_interceptor.dart';
import 'package:datn_mobile/shared/api_client/dio/interceptors/default_time_response_interceptor.dart';
import 'package:datn_mobile/shared/api_client/dio/interceptors/form_data_interceptor.dart';
import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/bootstrap.dart';
import 'package:datn_mobile/shared/api_client/dio/bad_certificate_fixer.dart';
import 'package:datn_mobile/shared/api_client/dio/interceptors/default_api_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

///This provider dioClient with interceptors(TimeResponseInterceptor,FormDataInterceptor,TalkerDioLogger,DefaultAPIInterceptor)
///with fixing bad certificate.
final dioPod = Provider.autoDispose<Dio>((ref) {
  final dio = Dio();
  final SecureStorage secureStorage = ref.read(secureStoragePod);

  dio.options.baseUrl = Config.baseUrl;
  if (kDebugMode) {
    dio.interceptors.add(TimeResponseInterceptor());
    dio.interceptors.add(FormDataInterceptor());
    dio.interceptors.add(
      TalkerDioLogger(
        talker: talker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
        ),
      ),
    );
  }

  dio.interceptors.addAll([
    DefaultAPIInterceptor(dio: dio, ref: ref),
    AuthorAPIInterceptor(dio: dio, secureStorage: secureStorage),
    // RetryInterceptor(
    //   dio: dio,
    //   logPrint: talker.log, // specify log function (optional)
    //   // retry count (optional)
    //   retries: 2,
    //   retryDelays: [
    //     const Duration(seconds: 2),
    //     const Duration(seconds: 4),
    //     const Duration(seconds: 6),
    //   ],
    //   retryEvaluator: (error, i) {
    //     // only retry on DioError
    //     if (error.error is SocketException) {
    //       // only retry on timeout error
    //       return true;
    //     } else {
    //       // coverage:ignore-line
    //       return false;
    //     }
    //   },
    // ),
  ]);
  fixBadCertificate(dio: dio);
  return dio;
}, name: 'dioProvider');
