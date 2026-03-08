import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds a transient error/info banner message for a specific class feed.
/// Set before navigating to ClassDetailRoute; cleared when user dismisses.
class ClassBannerNotifier extends Notifier<String?> {
  ClassBannerNotifier(this.classId);

  final String classId;

  @override
  String? build() => null;

  void show(String message) => state = message;
  void clear() => state = null;
}

final classBannerProvider =
    NotifierProvider.family<ClassBannerNotifier, String?, String>(
      (classId) => ClassBannerNotifier(classId),
    );
