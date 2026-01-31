import 'package:AIPrimary/features/notification/domain/entity/app_notification.dart';

abstract interface class NotificationApiService {
  Future<List<AppNotification>> getNotifications({int page = 0, int size = 20});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> registerDevice(String token);
}
