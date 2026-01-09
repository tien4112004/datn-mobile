import 'dart:io';

import 'package:datn_mobile/features/auth/data/dto/request/user_profile_update_request.dart';
import 'package:datn_mobile/features/auth/data/dto/response/user_profile_response.dart';
import 'package:datn_mobile/features/auth/data/sources/user_remote_source.dart';
import 'package:datn_mobile/features/auth/domain/entities/user_profile.dart';
import 'package:datn_mobile/features/auth/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteSource _remoteSource;

  UserRepositoryImpl(this._remoteSource);

  @override
  Future<UserProfile> getCurrentUser() async {
    final response = await _remoteSource.getCurrentUser();
    final dto = response.data!;
    return UserProfile(
      id: dto.id,
      email: dto.email,
      firstName: dto.firstName,
      lastName: dto.lastName,
      dateOfBirth: dto.dateOfBirth,
      phoneNumber: dto.phoneNumber ?? '',
      role: dto.role,
    );
  }

  @override
  Future<UserProfileResponse> getUserProfile(String userId) async {
    final response = await _remoteSource.getCurrentUser();
    return response.data!;
  }

  @override
  Future<UserProfileResponse> updateUserProfile(
    String userId,
    UserProfileUpdateRequest request,
  ) async {
    final response = await _remoteSource.updateUserProfile(userId, request);
    return response.data!;
  }

  @override
  Future<String> updateUserAvatar(String userId, File avatar) async {
    final response = await _remoteSource.updateUserAvatar(userId, avatar);
    return response.data!.avatarUrl;
  }

  @override
  Future<void> removeUserAvatar(String userId) async {
    await _remoteSource.removeUserAvatar(userId);
  }
}
