import 'package:datn_mobile/features/notification/data/source/notification_remote_source.dart';
import 'package:datn_mobile/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRemoteSourceProvider = Provider<NotificationRemoteSource>((
  ref,
) {
  return NotificationRemoteSource(ref.read(dioPod));
});
