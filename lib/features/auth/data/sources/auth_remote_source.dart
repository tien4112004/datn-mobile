import 'package:datn_mobile/features/auth/data/dto/request/credential_signin_request.dart';
import 'package:datn_mobile/features/auth/data/dto/token_response_dto.dart';
import 'package:datn_mobile/shared/api_client/response_dto/server_reponse_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

import 'package:datn_mobile/features/auth/data/dto/request/token_exchange_request.dart';

part 'auth_remote_source.g.dart';

@RestApi()
abstract class AuthRemoteSource {
  factory AuthRemoteSource(Dio dio, {String baseUrl}) = _AuthRemoteSource;

  @GET("/auth/google/signin")
  Future<String> getGoogleSignInUrl(@Query("redirect_uri") String redirectUri);

  @POST("/auth/exchange")
  Future<ServerResponseDto<TokenResponse>> handleGoogleSignInCallback(
    @Body() TokenExchangeRequest body,
  );

  @POST("/auth/signin")
  Future<ServerResponseDto<TokenResponse>> signIn(
    @Body() CredentialSigninRequest body,
  );
}
