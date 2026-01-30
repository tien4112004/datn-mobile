import 'dart:io';

import 'package:AIPrimary/core/secure_storage/secure_storage.dart';
import 'package:AIPrimary/features/auth/data/dto/request/user_profile_update_request.dart';
import 'package:AIPrimary/features/auth/data/dto/response/user_profile_response.dart';
import 'package:AIPrimary/features/auth/data/sources/user_remote_source.dart';
import 'package:AIPrimary/features/auth/domain/entities/user_profile.dart';
import 'package:AIPrimary/features/auth/domain/entities/user_role.dart';
import 'package:AIPrimary/features/auth/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteSource _remoteSource;
  final SecureStorage _secureStorage;

  UserRepositoryImpl(this._remoteSource, this._secureStorage);

  @override
  Future<UserProfile> getCurrentUser() async {
    final response = await _remoteSource.getCurrentUser();
    final dto = response.data!;
    final profile = UserProfile(
      id: dto.id,
      email: dto.email,
      firstName: dto.firstName,
      lastName: dto.lastName,
      dateOfBirth: dto.dateOfBirth ?? DateTime(1970, 1, 1),
      phoneNumber: dto.phoneNumber ?? '',
      role: UserRole.fromName(dto.role),
    );

    // Save to cache after fetching from API
    await saveCachedUser(profile);

    return profile;
  }

  @override
  Future<UserProfile?> getCachedUser() async {
    return await _secureStorage.loadUserProfile();
  }

  @override
  Future<void> saveCachedUser(UserProfile profile) async {
    await _secureStorage.saveUserProfile(profile);
  }

  @override
  Future<void> clearCachedUser() async {
    await _secureStorage.deleteUserProfile();
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
