import 'package:flutter_test/flutter_test.dart';
import 'package:AIPrimary/shared/exception/base_exception.dart';

void main() {
  group('APIException', () {
    test(
      'copyWith() should return a new APIException object with updated values',
      () {
        final exception = APIException(
          code: 404,
          errorCode: 'Not Found',
          errorMessage: 'Resource not found',
          timestamp: DateTime.now(),
        );

        final updatedException = exception.copyWith(
          code: 500,
          errorCode: 'Internal Server Error',
          errorMessage: 'Something went wrong',
        );
        expect(exception != updatedException, true);
        expect(exception.code, 404);
        expect(exception.errorCode, 'Not Found');
        expect(updatedException.code, 500);
        expect(updatedException.errorCode, equals('Internal Server Error'));
        expect(updatedException.errorMessage, equals('Something went wrong'));
        expect(updatedException.timestamp, isNotNull);
        final newexception = exception.copyWith(code: null, errorCode: null);
        expect(newexception.errorCode, 'Not Found');
        expect(newexception.code, 404);
      },
    );

    test('toMap() should return a map representation of the APIException', () {
      final exception = APIException(
        code: 404,
        errorCode: 'Not Found',
        errorMessage: 'Resource not found',
        timestamp: DateTime.now(),
      );

      final exceptionMap = exception.toMap();

      expect(exceptionMap['statusCode'], 404);
      expect(exceptionMap['statusMessage'], 'Not Found');
      expect(exceptionMap['errorMessage'], 'Resource not found');
      expect(exceptionMap['timestamp'], isNotNull);
    });

    test('fromMap() should create an APIException object from a map', () {
      final exceptionMap = {
        'statusCode': 500,
        'statusMessage': 'Internal Server Error',
        'errorMessage': 'Something went wrong',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final exception = APIException.fromMap(exceptionMap);

      expect(exception.code, 500);
      expect(exception.errorCode, 'Internal Server Error');
      expect(exception.errorMessage, 'Something went wrong');
      expect(exception.timestamp, isNotNull);
    });

    test('toJson() should return a JSON representation of the APIException', () {
      final exception = APIException(
        code: 404,
        errorCode: 'Not Found',
        errorMessage: 'Resource not found',
        timestamp: DateTime.now(),
      );

      final exceptionJson = exception.toJson();

      expect(
        exceptionJson,
        '{"statusCode":404,"statusMessage":"Not Found","errorMessage":"Resource not found","timestamp":"${exception.timestamp}"}',
      );
    });

    test(
      'fromJson() should create an APIException object from a JSON string',
      () {
        var timestamp = DateTime.now();
        final exceptionJson =
            '{"statusCode":500,"statusMessage":"Internal Server Error","errorMessage":"Something went wrong","timestamp":"$timestamp"}';

        final exception = APIException.fromJson(exceptionJson);

        expect(exception.code, 500);
        expect(exception.errorCode, 'Internal Server Error');
        expect(exception.errorMessage, 'Something went wrong');
        expect(exception.timestamp, isNotNull);
      },
    );

    test(
      'toString() should return a string representation of the APIException',
      () {
        final exception = APIException(
          code: 404,
          errorCode: 'Not Found',
          errorMessage: 'Resource not found',
          timestamp: DateTime.now(),
        );

        final exceptionString = exception.toString();

        expect(
          exceptionString,
          'APIException(statusCode: 404, statusMessage: Not Found, errorMessage: Resource not found, timestamp: ${exception.timestamp})',
        );
      },
    );

    test('equality check should work correctly for APIException objects', () {
      final exception1 = APIException(
        code: 404,
        errorCode: 'Not Found',
        errorMessage: 'Resource not found',
        timestamp: DateTime.now(),
      );

      final exception2 = APIException(
        code: 404,
        errorCode: 'Not Found',
        errorMessage: 'Resource not found',
        timestamp: exception1.timestamp,
      );

      expect(exception1, equals(exception2));
    });

    test(
      'hashCode should be calculated correctly for APIException objects',
      () {
        final exception = APIException(
          code: 404,
          errorCode: 'Not Found',
          errorMessage: 'Resource not found',
          timestamp: DateTime.now(),
        );

        final expectedHashCode =
            exception.code.hashCode ^
            exception.errorCode.hashCode ^
            exception.errorMessage.hashCode;

        expect(exception.hashCode, expectedHashCode);
      },
    );

    test('message should return the error message of the APIException', () {
      final exception = APIException(
        code: 404,
        errorCode: 'Not Found',
        errorMessage: 'Resource not found',
        timestamp: DateTime.now(),
      );

      expect(exception.message, 'Resource not found');
    });
  });
}
