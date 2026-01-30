import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:AIPrimary/shared/api_client/dio/interceptors/default_api_interceptor.dart';
import 'package:AIPrimary/shared/api_client/dio/interceptors/default_time_response_interceptor.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'package:AIPrimary/shared/api_client/dio/interceptors/form_data_interceptor.dart';

import 'package:talker_dio_logger/talker_dio_logger.dart';

void main() {
  group("dio Client Provider", () {
    test('expect dio.baseUrl should be "http://localhost:8080/api"', () {
      final container = ProviderContainer.test();
      final dio = container.read(dioPod);
      expect(
        dio,
        isA<DioForNative>()
            .having(
              (d) => d.options.baseUrl,
              'default interceptor should be 2',
              equals("http://localhost:8080/api"),
            )
            .having(
              (d) => d.interceptors.length,
              "Interceptors should be 5",
              equals(5),
            )
            .having(
              (d) => d.interceptors,
              "Contains a time response interceptor",
              containsAll([
                isA<TimeResponseInterceptor>(),
                isA<FormDataInterceptor>(),
                isA<TalkerDioLogger>(),
                isA<DefaultAPIInterceptor>(),
              ]),
            ),
      );
    });
  });
}
