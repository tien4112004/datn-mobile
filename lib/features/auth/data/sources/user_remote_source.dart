import 'dart:io';

import 'package:datn_mobile/features/auth/data/dto/request/user_profile_update_request.dart';
import 'package:datn_mobile/features/auth/data/dto/response/update_avatar_response.dart';
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

  @PUT('/user/me')
  Future<ServerResponseDto<UserProfileResponse>> updateUserProfile(
    @Path('userId') String userId,
    @Body() UserProfileUpdateRequest request,
  );

  @PATCH('/user/me/avatar')
  @MultiPart()
  Future<ServerResponseDto<UpdateAvatarResponse>> updateUserAvatar(
    @Path('userId') String userId,
    @Part(name: 'avatar') File avatar,
  );

  @DELETE('/user/me/avatar')
  Future<void> removeUserAvatar(@Path('userId') String userId);
}
