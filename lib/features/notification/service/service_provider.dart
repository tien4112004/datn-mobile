import 'package:datn_mobile/features/notification/data/dto/app_notification_dto.dart';
import 'package:datn_mobile/features/notification/data/source/notification_remote_source.dart';
import 'package:datn_mobile/features/notification/data/source/notification_remote_source_provider.dart';
import 'package:datn_mobile/features/notification/domain/entity/app_notification.dart';
import 'package:datn_mobile/features/notification/domain/service/notification_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'notification_api_service_impl.dart';

final notificationApiServiceProvider = Provider<NotificationApiService>((ref) {
  return NotificationApiServiceImpl(ref.read(notificationRemoteSourceProvider));
});
