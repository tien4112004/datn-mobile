import 'package:datn_mobile/features/auth/data/dto/response/user_profile_response.dart';
import 'package:datn_mobile/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'user_remote_source.g.dart';

@RestApi()
abstract class UserRemoteSource {
  factory UserRemoteSource(Dio dio, {String baseUrl}) = _UserRemoteSource;

  @GET('/user/me')
  Future<ServerResponseDto<UserProfileResponse>> getCurrentUser();
}
