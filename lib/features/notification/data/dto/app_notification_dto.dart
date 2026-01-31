import 'package:AIPrimary/features/notification/domain/entity/app_notification.dart';
import 'package:AIPrimary/features/notification/domain/entity/notification_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_notification_dto.g.dart';

@JsonSerializable()
class AppNotificationDto {
  final String id;
  final String title;
  final String? body;
  final String type;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  AppNotificationDto({
    required this.id,
    required this.title,
    this.body,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotificationDto.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AppNotificationDtoToJson(this);
}

extension AppNotificationDtoMapper on AppNotificationDto {
  AppNotification toEntity() {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: NotificationType.fromString(type),
      referenceId: referenceId,
      isRead: isRead,
      createdAt: createdAt,
    );
  }
}

extension AppNotificationEntityMapper on AppNotification {
  AppNotificationDto toDto() {
    return AppNotificationDto(
      id: id,
      title: title,
      body: body,
      type: type.toApiValue(),
      referenceId: referenceId,
      isRead: isRead,
      createdAt: createdAt,
    );
  }
}
