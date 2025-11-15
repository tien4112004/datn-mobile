# Error Handling Pattern - Flutter/Dart Implementation

## Overview

We've implemented a comprehensive error handling system for the Flutter app, inspired by your frontend TypeScript architecture. This ensures consistent, predictable error handling across service layers.

## Architecture

### 1. Error Types & Severity Levels

**`app_error.dart`** - Core error definitions with two severity levels:

```dart
enum ErrorSeverity {
  critical,  // Requires immediate attention
  warning,   // Expected/recoverable errors
}

enum ErrorType {
  unknown,
  network,
  authentication,
  authorization,
  validation,
  serverError,
  parsing,
  storage,
  timeout,
  cancelled,
}
```

### 2. Error Classes

#### **AppError** (Interface)
- Base contract for all app errors
- Properties: `severity`, `type`, `message`, `code`, `context`, `timestamp`
- Allows type-safe error handling across the app

#### **CriticalError** (Extends AppError)
- Severity: `ErrorSeverity.critical`
- Examples: Unexpected crashes, storage failures, unknown errors
- Should trigger error reporting/logging

#### **ExpectedError** (Extends AppError)
- Severity: `ErrorSeverity.warning`
- Examples: Network issues, validation failures, auth errors
- Can be handled gracefully with user feedback

#### **APIException** (Extends ExpectedError)
- Legacy compatibility with existing code
- Now includes HTTP status code mapping
- Automatically categorizes errors by HTTP status

### 3. Error Context & Metadata

Each error can carry context:

```dart
ExpectedError(
  message: 'Failed to store authentication tokens',
  type: ErrorType.storage,
  code: 'STORAGE_ERROR',
  context: {
    'originalError': e.toString(),
    'operation': 'sign-in',
    'timestamp': DateTime.now().toIso8601String(),
  },
)
```

This enables:
- Better debugging with detailed context
- User analytics and error tracking
- Server-side error aggregation

## Usage in Service Layer

### Error Throwing Strategy

```dart
// 1. Validate server responses
void _validateResponse<T>(ServerResponseDto<T> response, String operation) {
  if (!response.success) {
    throw ExpectedError(
      message: response.message ?? 'Operation failed',
      type: _mapHttpStatusToErrorType(response.code),
      code: '${response.code}',
      context: {...},
    );
  }
}

// 2. Wrap unexpected errors
Never _rethrowAsAppError(dynamic error, String operation) {
  if (error is AppError) throw error;
  
  throw CriticalError(
    message: 'Unexpected error during $operation',
    type: ErrorType.unknown,
    context: {'operation': operation},
  );
}

// 3. Map HTTP status codes
ErrorType _mapHttpStatusToErrorType(int? statusCode) {
  switch (statusCode) {
    case 400 || 422: return ErrorType.validation;
    case 401: return ErrorType.authentication;
    case 403: return ErrorType.authorization;
    case 408 || 504: return ErrorType.timeout;
    case 500 || 502 || 503: return ErrorType.serverError;
    default: return ErrorType.unknown;
  }
}
```

### Error Handling in Service Methods

```dart
@override
Future<void> signInWithEmailAndPassword({
  required String email,
  required String password,
}) async {
  try {
    // 1. Call remote source
    final response = await authRemoteSource.signIn(...);
    
    // 2. Validate response
    _validateResponse(response, 'sign-in');
    
    // 3. Process data
    final tokenResponse = response.data as TokenResponse;
    
    // 4. Handle side effects with try-catch
    try {
      await secureStorage.write(key: R.ACCESS_TOKEN_KEY, value: token);
    } catch (e) {
      throw ExpectedError(
        message: 'Failed to store tokens',
        type: ErrorType.storage,
        context: {'originalError': e.toString()},
      );
    }
  } catch (error) {
    // 5. Re-throw as AppError
    _rethrowAsAppError(error, 'sign-in');
  }
}
```

## Type Guards & Utilities

### Check Error Severity

```dart
if (isCriticalError(error)) {
  // Log to Sentry, show critical alert
} else if (isExpectedError(error)) {
  // Show user-friendly message
}
```

### Create Errors Programmatically

```dart
final error = createAppError(
  message: 'Custom error message',
  severity: ErrorSeverity.critical,
  type: ErrorType.authentication,
  code: 'AUTH_001',
  context: {'userId': '123'},
);
```

## Controller/UI Layer Usage

In your Riverpod controller, catch and expose errors:

```dart
@riverpod
class AuthController extends StateNotifier<AsyncValue<void>> {
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        await _authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (error) {
        if (error is AppError) {
          // Log with context
          log('Auth error: ${error.message}', 
            error: error, 
            stackTrace: StackTrace.current);
          
          // Re-throw to AsyncValue for UI handling
          rethrow;
        }
        rethrow;
      }
    });
  }
}
```

## Best Practices

✅ **DO**
- Always wrap service method logic in try-catch
- Validate server responses before using data
- Add meaningful context to errors
- Use appropriate `ErrorType` for categorization
- Distinguish between `CriticalError` and `ExpectedError`
- Log errors with full context before throwing

❌ **DON'T**
- Throw generic `Exception` or bare strings
- Silently catch and ignore errors
- Re-throw without adding context
- Mix raw `APIException` with `AppError`
- Forget to handle side effects (storage, etc.)

## Migration Path

Existing code using `APIException` continues to work:

```dart
// Old code still works - APIException is now ExpectedError
if (response is APIException) {
  throw response; // Actually throws ExpectedError
}
```

### Migrate to New Pattern

```dart
// Before
throw APIException(
  code: 400,
  errorMessage: 'Invalid input',
);

// After
throw ExpectedError(
  message: 'Invalid input',
  type: ErrorType.validation,
  code: '400',
  context: {'httpStatus': 400},
);
```

## Comparison with TypeScript

| TypeScript | Dart |
|-----------|------|
| `AppError` interface | `AppError` abstract class |
| `CriticalError` | `CriticalError` (class) |
| `ExpectedError` | `ExpectedError` (class) |
| `createError()` function | `createAppError()` function |
| `isCriticalError()` | `isCriticalError()` function |
| `error.severity` property | `error.severity` property |
| `error.type` property | `error.type` property |
| `Record<string, unknown>` | `Map<String, dynamic>` |

**Key Differences:**
- Dart uses classes instead of interfaces/records
- No need for `instanceof` checks - use Dart's type system
- `Never` return type instead of `throw`
- Full compatibility with existing `APIException`

## Summary

This implementation provides:
- ✅ Structured error hierarchy matching TypeScript pattern
- ✅ Rich error context for debugging
- ✅ Type-safe error handling
- ✅ Automatic HTTP status categorization
- ✅ Backward compatibility with existing code
- ✅ Clear separation of concerns in service layer
