import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper class for formatting dates with relative time display
///
/// This helper provides consistent date formatting across the application
/// with support for relative time labels (e.g., "2 hours ago", "yesterday")
class DateFormatHelper {
  /// Format a date with relative time display
  ///
  /// Returns:
  /// - Relative time strings for recent dates (e.g., "5 minutes ago", "2 hours ago")
  /// - "yesterday" for dates exactly 1 day ago
  /// - Days ago for dates within the last week (e.g., "3 days ago")
  /// - Formatted date string (dd/mm/yyyy) for older dates
  static String formatRelativeDate(DateTime date, {required WidgetRef ref}) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final t = ref.read(translationsPod);

    if (difference.inMinutes < 60) {
      return t.projects.minutes_ago(count: difference.inMinutes);
    } else if (difference.inHours < 24) {
      return t.projects.hours_ago(count: difference.inHours);
    } else if (difference.inDays == 1) {
      return t.projects.yesterday;
    } else if (difference.inDays < 7) {
      return t.projects.days_ago(count: difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Format a date to a simple date string (dd/mm/yyyy)
  static String formatSimpleDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format a date to a full date-time string
  ///
  /// Example: "07/11/2025 14:30"
  static String formatFullDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} $hour:$minute';
  }

  /// Get the relative time difference between two dates
  ///
  /// Returns a human-readable string like "2 hours 30 minutes"
  static String getTimeDifference(DateTime start, DateTime end) {
    final difference = end.difference(start);

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    final parts = <String>[];

    if (days > 0) {
      parts.add('$days day${days > 1 ? 's' : ''}');
    }
    if (hours > 0) {
      parts.add('$hours hour${hours > 1 ? 's' : ''}');
    }
    if (minutes > 0) {
      parts.add('$minutes minute${minutes > 1 ? 's' : ''}');
    }

    return parts.isEmpty ? '0 minutes' : parts.join(' ');
  }
}
