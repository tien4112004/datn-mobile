/// Thrown when payment verification exceeds total timeout duration
class PaymentTimeoutException implements Exception {
  final String message;
  final String? transactionId;
  final Duration timeElapsed;

  PaymentTimeoutException({
    required this.message,
    this.transactionId,
    required this.timeElapsed,
  });

  @override
  String toString() => 'PaymentTimeoutException: $message';
}

/// Thrown when max retries exceeded or verification fails
class PaymentVerificationException implements Exception {
  final String message;
  final String? transactionId;
  final int attemptsMade;
  final Object? originalError;

  PaymentVerificationException({
    required this.message,
    this.transactionId,
    required this.attemptsMade,
    this.originalError,
  });

  @override
  String toString() =>
      'PaymentVerificationException: $message (attempts: $attemptsMade)';
}
