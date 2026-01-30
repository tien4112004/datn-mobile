// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:AIPrimary/shared/helper/date_format_helper.dart';

///This is the base class exception which can be
///used to throw with a message
class BaseException implements Exception {
  BaseException({this.message = 'Unknown Error'});
  final String message;
}

///This class used to throw error from API Providers
class APIException implements BaseException {
  final int? code;
  final String? errorCode;
  final String errorMessage;
  final DateTime timestamp;
  APIException({
    this.code,
    this.errorCode,
    required this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateFormatHelper.getNow();

  APIException copyWith({int? code, String? errorCode, String? errorMessage}) {
    return APIException(
      code: code ?? this.code,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'statusCode': code,
      'statusMessage': errorCode,
      'errorMessage': errorMessage,
      'timestamp': timestamp.toString(),
    };
  }

  factory APIException.fromMap(Map<String, dynamic> map) {
    return APIException(
      code: map['statusCode']?.toInt(),
      errorCode: map['statusMessage'],
      errorMessage: map['errorMessage'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateFormatHelper.getNow(),
    );
  }

  String toJson() => json.encode(toMap());

  factory APIException.fromJson(String source) =>
      APIException.fromMap(json.decode(source));

  @override
  String toString() =>
      'APIException(statusCode: $code, statusMessage: $errorCode, errorMessage: $errorMessage, timestamp: $timestamp)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is APIException &&
        other.code == code &&
        other.errorCode == errorCode &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode =>
      code.hashCode ^ errorCode.hashCode ^ errorMessage.hashCode;

  @override
  String get message => errorMessage;
}
