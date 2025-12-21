import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DioErrorMessage extends ConsumerWidget {
  final Object error;
  final bool showDioDetails;
  final Color textColor;

  const DioErrorMessage({
    required this.error,
    required this.showDioDetails,
    required this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    String message;
    if (showDioDetails && error is DioException) {
      final dioError = error as DioException;
      message = switch (dioError.type) {
        DioExceptionType.connectionTimeout => t.errors.dio.connectionTimeout,
        DioExceptionType.sendTimeout => t.errors.dio.sendTimeout,
        DioExceptionType.receiveTimeout => t.errors.dio.receiveTimeout,
        DioExceptionType.badCertificate => t.errors.dio.badCertificate,
        DioExceptionType.badResponse => t.errors.dio.badResponse,
        DioExceptionType.cancel => t.errors.dio.cancel,
        DioExceptionType.connectionError => t.errors.dio.connectionError,
        DioExceptionType.unknown => t.errors.dio.unknown,
      };
    } else {
      message = error.toString();
    }

    return Text(
      message,
      style: TextStyle(color: textColor),
      textAlign: TextAlign.center,
    );
  }
}
