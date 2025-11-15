# 🎯 Error Handling Architecture - Visual Overview

## TypeScript Frontend Pattern → Dart Mobile Implementation

### Your Original TypeScript Structure
```typescript
interface AppError extends Error {
  severity: ErrorSeverity;     // CRITICAL | WARNING
  type: ErrorType;              // UNKNOWN | NETWORK | AUTH | ...
  code?: string;                // "500", "AUTH_001", etc.
  context?: Record<string, unknown>;  // Metadata
  timestamp: Date;              // When error occurred
}

class CriticalError extends Error implements AppError
class ExpectedError extends Error implements AppError

createError(...) → AppError
isCriticalError(error) → boolean
```

### Dart Mobile Implementation ✅

```dart
enum ErrorSeverity { critical, warning }
enum ErrorType { unknown, network, authentication, ... }

abstract class AppError implements Exception {
  ErrorSeverity get severity;
  ErrorType get type;
  String get message;
  String? get code;
  Map<String, dynamic>? get context;
  DateTime get timestamp;
}

class CriticalError extends AppError
class ExpectedError extends AppError
class APIException extends ExpectedError  // Backward compatible

createAppError(...) → AppError
isCriticalError(error) → bool
isExpectedError(error) → bool
```

---

## Error Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Remote Operation                          │
│                  (API call, Storage, etc.)                   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │  Response/Result     │
              │ - success: bool      │
              │ - code: int          │
              │ - data: T?           │
              │ - message: String?   │
              └──────────────────────┘
                         │
                         ▼
              ┌──────────────────────────┐
              │ _validateResponse()      │
              │ - Check response.success │
              │ - Map HTTP code→ErrorType│
              └────────┬─────────────────┘
                       │
          ┌────────────┴────────────┐
          │ Success ✓              │ Failure ✗
          ▼                        ▼
    ┌──────────────┐    ┌─────────────────────┐
    │ Process      │    │ Throw ExpectedError │
    │ response.data│    │ - type: ErrorType   │
    │             │    │ - code: String      │
    │ Side effect  │    │ - context: {...}    │
    │ (storage)    │    │ - timestamp: now    │
    └────────┬─────┘    └────────┬────────────┘
             │                   │
             │ Side-effect       │
             │ error?            │
             ▼                   ▼
    ┌──────────────────┐   ┌──────────────┐
    │ Success! ✓       │   │ Catch & throw│
    │ Return normally  │   │ ExpectedError│
    └──────────────────┘   └──────┬───────┘
                                  │
                                  ▼
                    ┌─────────────────────────────┐
                    │  _rethrowAsAppError()       │
                    │ - Wrap unknown errors       │
                    │ - Preserve AppError as-is   │
                    │ - Create CriticalError for  │
                    │   unexpected failures       │
                    └─────────────┬───────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    ▼                           ▼
            ┌──────────────────┐      ┌──────────────────┐
            │ CriticalError    │      │ ExpectedError    │
            │ severity:        │      │ severity:        │
            │  CRITICAL        │      │  WARNING         │
            │                  │      │                  │
            │ Action:          │      │ Action:          │
            │ - Log critical   │      │ - Show message   │
            │ - Send to        │      │ - Retry if       │
            │   Sentry         │      │   transient      │
            │ - Alert user     │      │ - Guide user     │
            └──────────────────┘      └──────────────────┘
                    │                           │
                    └─────────────┬─────────────┘
                                  ▼
                    ┌─────────────────────────────┐
                    │  UI/Controller receives     │
                    │  AsyncValue<Error> or       │
                    │  catches in try-catch       │
                    └─────────────────────────────┘
```

---

## Error Type Mapping

```
HTTP Status  →  ErrorType          →  User Message
─────────────────────────────────────────────────────
400/422      →  validation         →  "Check your input"
401          →  authentication     →  "Please log in"
403          →  authorization      →  "No permission"
408/504      →  timeout            →  "Request timed out"
500/502/503  →  serverError        →  "Server error"
???          →  unknown            →  "Unknown error"
```

---

## Error Context Example

```dart
ExpectedError(
  message: 'Failed to sign in',
  type: ErrorType.authentication,
  code: '401',
  context: {
    // HTTP details
    'httpStatus': 401,
    'errorCode': 'INVALID_CREDENTIALS',
    
    // Operation context
    'operation': 'sign-in',
    'email': 'user@example.com',
    'timestamp': '2024-11-10T10:30:00Z',
    
    // Debugging info
    'retryCount': 1,
    'endpoint': '/api/auth/signin',
    'method': 'POST',
  },
)
```

**When logged to Sentry/Firebase:**
```json
{
  "message": "Failed to sign in",
  "severity": "warning",
  "type": "authentication",
  "code": "401",
  "timestamp": "2024-11-10T10:30:00Z",
  "breadcrumbs": {
    "operation": "sign-in",
    "email": "user@example.com",
    "retryCount": 1
  }
}
```

---

## Usage Pattern Summary

### Service Layer
```
Method call
    ↓
Try-catch block
    ├─ Validate response → throw ExpectedError
    ├─ Check data → throw ExpectedError
    ├─ Handle side effects → throw ExpectedError
    └─ Catch all → _rethrowAsAppError()
    ↓
Throw CriticalError or ExpectedError
```

### Controller Layer
```
Service call
    ↓
AsyncValue.guard()
    ├─ Success → state = AsyncValue.data()
    └─ Error → state = AsyncValue.error()
    ↓
UI accesses state.when()
```

### UI Layer
```
AsyncValue.when()
    ├─ data: show content
    ├─ loading: show spinner
    └─ error: 
        ├─ if (isCriticalError) → show alert
        └─ else → show snackbar with message
```

---

## Before vs After Comparison

### ❌ BEFORE (Limited)
```dart
// Inconsistent error handling
try {
  await authRemoteSource.signIn(...);
} catch (e) {
  log('Error: $e');
  rethrow;  // Lost context!
}

// Limited information
throw APIException(
  code: 401,
  errorMessage: 'Invalid credentials',
);

// Hard to categorize errors
if (e.code == 401) {
  // Auth error?
} else if (e.code == 500) {
  // Server error?
}
```

### ✅ AFTER (Comprehensive)
```dart
// Consistent error handling with context
try {
  final response = await authRemoteSource.signIn(...);
  _validateResponse(response, 'sign-in');  // Automatic categorization!
  // ... process data ...
} catch (error) {
  _rethrowAsAppError(error, 'sign-in');  // Preserved context!
}

// Rich, categorized error
throw ExpectedError(
  message: 'Invalid credentials',
  type: ErrorType.authentication,
  code: '401',
  context: {
    'operation': 'sign-in',
    'email': 'user@email.com',
  },
);

// Easy type checking
if (error.type == ErrorType.authentication) {
  // Auth error
} else if (isCriticalError(error)) {
  // Critical error
}
```

---

## File Structure

```
lib/
├── shared/
│   └── exception/
│       ├── app_error.dart                    [NEW] ← Core error system
│       ├── base_exception.dart               [UPDATED] ← Backward compatible
│       └── error_handling_examples.dart      [NEW] ← Usage examples
│
├── features/
│   └── auth/
│       └── service/
│           └── auth_service_impl.dart        [UPDATED] ← Reference implementation
│
├── ERROR_HANDLING_GUIDE.md                  [NEW] ← Full documentation
└── ERROR_HANDLING_IMPLEMENTATION_SUMMARY.md [NEW] ← This summary
```

---

## Key Takeaways ✨

1. **Structured** - Every error has severity, type, code, context, timestamp
2. **Consistent** - Same pattern across all services
3. **Debuggable** - Rich context for troubleshooting
4. **Categorical** - 10 error types for proper handling
5. **Type-safe** - Compile-time error type checking
6. **Backward Compatible** - Existing `APIException` code works
7. **Observable** - Easy to track and analyze errors
