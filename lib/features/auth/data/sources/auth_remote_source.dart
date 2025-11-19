import 'package:datn_mobile/features/auth/data/dto/request/credential_signin_request.dart';
import 'package:datn_mobile/features/auth/data/dto/request/credential_signup_request.dart';
import 'package:datn_mobile/features/auth/data/dto/response/token_response.dart';
import 'package:datn_mobile/features/auth/data/dto/response/user_profile_response.dart';
import 'package:datn_mobile/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

import 'package:datn_mobile/features/auth/data/dto/request/token_exchange_request.dart';

part 'auth_remote_source.g.dart';

@RestApi()
abstract class AuthRemoteSource {
  factory AuthRemoteSource(Dio dio, {String baseUrl}) = _AuthRemoteSource;

  // !! DEPRECATED
  // This endpoint is no longer in use since we need to use Dio directly
  // in order to follow redirects automatically.
  // @GET("/auth/google/authorize")
  // Future<HttpResponse> getGoogleSignInUrl(
  //   @Query("clientType") String redirectUri,
  // );

  @POST("/auth/exchange")
  Future<ServerResponseDto<TokenResponse>> handleGoogleSignInCallback(
    @Body() TokenExchangeRequest body,
  );

  @POST("/auth/signin")
  Future<ServerResponseDto<TokenResponse>> signIn(
    @Body() CredentialSigninRequest body,
  );

  @POST("/auth/signup")
  Future<ServerResponseDto<UserProfileResponse>> signup(
    @Body() CredentialSignupRequest body,
  );

  @POST("/auth/logout")
  Future<ServerResponseDto<void>> logout();
}
