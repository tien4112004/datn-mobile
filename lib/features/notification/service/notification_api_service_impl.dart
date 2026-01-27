part of 'service_provider.dart';

class NotificationApiServiceImpl implements NotificationApiService {
  final NotificationRemoteSource _remoteSource;

  NotificationApiServiceImpl(this._remoteSource);

  @override
  Future<List<AppNotification>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _remoteSource.getNotifications(
      page: page,
      size: size,
    );
    return response.data?.map((dto) => dto.toEntity()).toList() ?? [];
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _remoteSource.getUnreadCount();
    return response.data?.count ?? 0;
  }

  @override
  Future<void> markAsRead(String id) async {
    await _remoteSource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() async {
    await _remoteSource.markAllAsRead();
  }

  @override
  Future<void> registerDevice(String token) async {
    await _remoteSource.registerDevice({'token': token});
  }
}
