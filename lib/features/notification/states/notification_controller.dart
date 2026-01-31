import 'package:AIPrimary/features/notification/domain/service/notification_api_service.dart';
import 'package:AIPrimary/features/notification/service/service_provider.dart';
import 'package:AIPrimary/features/notification/states/notification_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, NotificationState>(() {
      return NotificationController();
    });

class NotificationController extends AsyncNotifier<NotificationState> {
  static const int _pageSize = 20;
  NotificationApiService get _service =>
      ref.read(notificationApiServiceProvider);

  @override
  NotificationState build() {
    return const NotificationState();
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    final currentState = state.value ?? const NotificationState();
    if (currentState.isLoading) return;

    final page = refresh ? 0 : currentState.currentPage;

    state = AsyncData(currentState.copyWith(isLoading: true, error: null));

    try {
      final notifications = await _service.getNotifications(
        page: page,
        size: _pageSize,
      );

      final newNotifications = refresh
          ? notifications
          : [...currentState.notifications, ...notifications];

      state = AsyncData(
        currentState.copyWith(
          notifications: newNotifications,
          isLoading: false,
          currentPage: page + 1,
          hasMore: notifications.length >= _pageSize,
        ),
      );
    } catch (e) {
      state = AsyncData(
        currentState.copyWith(isLoading: false, error: e.toString()),
      );
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      final count = await _service.getUnreadCount();
      final currentState = state.value ?? const NotificationState();
      state = AsyncData(currentState.copyWith(unreadCount: count));
    } catch (e) {
      // Silently fail for unread count
    }
  }

  Future<void> markAsRead(String id) async {
    final currentState = state.value ?? const NotificationState();
    try {
      await _service.markAsRead(id);

      final updatedNotifications = currentState.notifications.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      state = AsyncData(
        currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: currentState.unreadCount > 0
              ? currentState.unreadCount - 1
              : 0,
        ),
      );
    } catch (e) {
      state = AsyncData(currentState.copyWith(error: e.toString()));
    }
  }

  Future<void> markAllAsRead() async {
    final currentState = state.value ?? const NotificationState();
    try {
      await _service.markAllAsRead();

      final updatedNotifications = currentState.notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();

      state = AsyncData(
        currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        ),
      );
    } catch (e) {
      state = AsyncData(currentState.copyWith(error: e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadNotifications(refresh: true);
    await loadUnreadCount();
  }
}
