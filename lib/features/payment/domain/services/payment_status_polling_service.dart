import 'dart:math' as math;
import 'dart:math';

import 'package:AIPrimary/features/payment/data/models/transaction_details_model.dart';
import 'package:AIPrimary/features/payment/data/repositories/payment_repository.dart';
import 'package:flutter/foundation.dart';

import '../exceptions/payment_exceptions.dart';

class PaymentStatusPollingService {
  final PaymentRepository _repository;

  PaymentStatusPollingService(this._repository);

  static const int maxRetries = 8;
  static const Duration initialDelay = Duration(seconds: 2);
  static const Duration maxDelay = Duration(seconds: 30);
  static const Duration totalTimeout = Duration(minutes: 3);
  static const double backoffMultiplier = 1.5;
  static const double jitterFactor = 0.1; // ±10% randomness

  /// Polls transaction status with exponential backoff until final status reached
  ///
  /// [transactionId] - The transaction ID to check
  /// [onRetry] - Optional callback invoked before each retry with attempt number and next delay
  ///
  /// Returns the transaction with final status (SUCCESS/FAILED/CANCELLED)
  ///
  /// Throws:
  /// - [PaymentTimeoutException] if total timeout exceeded
  /// - [PaymentVerificationException] if max retries exceeded or verification fails
  Future<TransactionDetailsModel> pollTransactionStatus({
    required String transactionId,
    void Function(int attempt, Duration nextDelay)? onRetry,
  }) async {
    final startTime = DateTime.now();

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      // Check timeout
      if (DateTime.now().difference(startTime) > totalTimeout) {
        throw PaymentTimeoutException(
          message:
              'Payment verification timeout after ${totalTimeout.inMinutes} minutes',
          transactionId: transactionId,
          timeElapsed: DateTime.now().difference(startTime),
        );
      }

      try {
        // Fetch transaction status
        final transaction = await _repository.getTransactionDetails(
          transactionId,
        );

        // Check if status is final
        if (_isFinalStatus(transaction.status)) {
          return transaction;
        }

        // Still pending, calculate next delay
        if (attempt < maxRetries - 1) {
          final nextDelay = _calculateNextDelay(attempt + 1);
          onRetry?.call(attempt + 1, nextDelay);
          await Future.delayed(nextDelay);
        }
      } catch (e) {
        // Log error but continue retrying
        debugPrint(
          'Error fetching transaction status (attempt ${attempt + 1}): $e',
        );
        if (attempt == maxRetries - 1) {
          throw PaymentVerificationException(
            message:
                'Failed to verify payment status after $maxRetries attempts',
            transactionId: transactionId,
            attemptsMade: attempt + 1,
            originalError: e,
          );
        }
      }
    }

    // Max retries exceeded and still pending
    throw PaymentVerificationException(
      message: 'Payment still pending after $maxRetries verification attempts',
      transactionId: transactionId,
      attemptsMade: maxRetries,
    );
  }

  /// Calculates next delay with exponential backoff and jitter
  Duration _calculateNextDelay(int attemptNumber) {
    // Exponential backoff
    final baseDelay =
        initialDelay.inMilliseconds *
        math.pow(backoffMultiplier, attemptNumber);

    // Add random jitter (±10%)
    final random = Random();
    final jitter = baseDelay * jitterFactor * (random.nextDouble() * 2 - 1);
    final delayMs = (baseDelay + jitter).clamp(
      initialDelay.inMilliseconds.toDouble(),
      maxDelay.inMilliseconds.toDouble(),
    );

    return Duration(milliseconds: delayMs.toInt());
  }

  /// Checks if transaction status is final (non-pending)
  bool _isFinalStatus(String status) {
    return status == 'SUCCESS' ||
        status == 'COMPLETED' ||
        status == 'FAILED' ||
        status == 'CANCELLED';
  }
}
