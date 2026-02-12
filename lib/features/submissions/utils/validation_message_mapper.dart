import 'package:AIPrimary/i18n/strings.g.dart';

/// Maps backend validation error messages to localized strings
class ValidationMessageMapper {
  /// Extract question name from message like "Question 'ABC' is not answered"
  static String? _extractQuestionName(String message) {
    final regex = RegExp(r"Question '([^']+)' is not answered");
    final match = regex.firstMatch(message);
    return match?.group(1);
  }

  /// Extract attempt limit from message like "Maximum submission limit reached (1)"
  static int? _extractAttemptLimit(String message) {
    final regex = RegExp(r'Maximum submission limit reached \((\d+)\)');
    final match = regex.firstMatch(message);
    return match != null ? int.tryParse(match.group(1) ?? '') : null;
  }

  /// Map backend error message to localized string
  static String mapError(String backendMessage, Translations t) {
    // Maximum submission limit reached
    if (backendMessage.contains('Maximum submission limit reached')) {
      final limit = _extractAttemptLimit(backendMessage);
      if (limit != null) {
        return t.submissions.errors.maxSubmissionLimitReached(limit: limit);
      }
      return t.submissions.preview.attemptLimitReached;
    }

    // Assignment expired
    if (backendMessage.contains('expired') ||
        backendMessage.contains('Assignment has ended')) {
      return t.submissions.errors.assignmentExpired;
    }

    // Assignment not available
    if (backendMessage.contains('not available') ||
        backendMessage.contains('not open')) {
      return t.submissions.errors.assignmentNotAvailable;
    }

    // Question not answered (treat as warning, but can appear in errors)
    final questionName = _extractQuestionName(backendMessage);
    if (questionName != null) {
      return t.submissions.errors.questionNotAnswered(question: questionName);
    }

    // Fallback: return original message
    return backendMessage;
  }

  /// Map list of error messages
  static List<String> mapErrors(List<String> messages, Translations t) {
    return messages.map((msg) => mapError(msg, t)).toList();
  }
}
