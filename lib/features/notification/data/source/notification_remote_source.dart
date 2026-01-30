import 'package:AIPrimary/features/notification/data/dto/app_notification_dto.dart';
import 'package:AIPrimary/features/notification/data/dto/unread_count_dto.dart';
import 'package:AIPrimary/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'notification_remote_source.g.dart';

@RestApi()
abstract class NotificationRemoteSource {
  factory NotificationRemoteSource(Dio dio, {String baseUrl}) =
      _NotificationRemoteSource;

  @GET("/notifications")
  Future<ServerResponseDto<List<AppNotificationDto>>> getNotifications({
    @Query("page") int page = 0,
    @Query("size") int size = 20,
  });

  @GET("/notifications/unread-count")
  Future<ServerResponseDto<UnreadCountDto>> getUnreadCount();

  @PUT("/notifications/{id}/read")
  Future<void> markAsRead(@Path("id") String id);

  @PUT("/notifications/read-all")
  Future<void> markAllAsRead();

  @POST("/notifications/device")
  Future<void> registerDevice(@Body() Map<String, String> body);
}
