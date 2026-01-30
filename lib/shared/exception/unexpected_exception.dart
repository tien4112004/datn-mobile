import 'package:AIPrimary/shared/exception/base_exception.dart';

class UnexpectedException extends APIException {
  UnexpectedException({
    required this.httpCode,
    super.errorCode,
    required super.errorMessage,
  });

  final int httpCode;
}

class CriticalException extends APIException {
  CriticalException({required super.errorMessage});
}

class AnotherException extends APIException {
  AnotherException({required super.errorMessage});
}
