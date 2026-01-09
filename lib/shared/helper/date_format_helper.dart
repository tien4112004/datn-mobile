import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Helper class for formatting dates with relative time display
///
/// This helper provides consistent date formatting across the application
/// with support for relative time labels (e.g., "2 hours ago", "yesterday")
/// and proper locale-specific formatting
class DateFormatHelper {
  /// Get the current locale from the app's translation settings
  static String _getLocale(WidgetRef ref) {
    final locale = ref.read(translationsPod).$meta.locale.languageTag;
    return locale;
  }

  // Get now with locale time zone
  static DateTime getNow() {
    return DateTime.now().toLocal();
  }

  /// Format a date with relative time display
  ///
  /// Returns:
  /// - Relative time strings for recent dates (e.g., "5 minutes ago", "2 hours ago")
  /// - "yesterday" for dates exactly 1 day ago
  /// - Days ago for dates within the last week (e.g., "3 days ago")
  /// - Formatted date string (locale-aware format) for older dates
  static String formatRelativeDate(DateTime date, {required WidgetRef ref}) {
    final now = DateFormatHelper.getNow();
    final difference = now.difference(date);
    final t = ref.read(translationsPod);
    final locale = _getLocale(ref);

    if (difference.inMinutes < 60) {
      return t.projects.minutes_ago(count: difference.inMinutes);
    } else if (difference.inHours < 24) {
      return t.projects.hours_ago(count: difference.inHours);
    } else if (difference.inDays == 1) {
      return t.projects.yesterday;
    } else if (difference.inDays < 7) {
      return t.projects.days_ago(count: difference.inDays);
    } else {
      // Use locale-specific date format
      return DateFormat.yMd(locale).format(date);
    }
  }

  /// Format a date to a simple date string (locale-aware format)
  ///
  /// Example: "1/7/2026" (en) or "7/1/2026" (vi)
  static String formatSimpleDate(DateTime date, {required WidgetRef ref}) {
    final locale = _getLocale(ref);
    return DateFormat.yMd(locale).format(date);
  }

  /// Format a date to a full date-time string (locale-aware format)
  ///
  /// Example: "1/7/2026, 2:30 PM" (en) or "7/1/2026 14:30" (vi)
  static String formatFullDateTime(DateTime date, {required WidgetRef ref}) {
    final locale = _getLocale(ref);
    return DateFormat.yMd(locale).add_Hm().format(date);
  }

  /// Format a date with a medium date format
  ///
  /// Example: "Jan 7, 2026" (en) or "7 thg 1, 2026" (vi)
  static String formatMediumDate(DateTime date, {required WidgetRef ref}) {
    final locale = _getLocale(ref);
    return DateFormat.yMMMd(locale).format(date);
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
