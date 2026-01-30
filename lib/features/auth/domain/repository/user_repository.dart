import 'dart:io';

import 'package:AIPrimary/features/auth/data/dto/request/user_profile_update_request.dart';
import 'package:AIPrimary/features/auth/data/dto/response/user_profile_response.dart';
import 'package:AIPrimary/features/auth/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile> getCurrentUser();
  Future<UserProfile?> getCachedUser();
  Future<void> saveCachedUser(UserProfile profile);
  Future<void> clearCachedUser();

  Future<UserProfileResponse> getUserProfile(String userId);

  Future<UserProfileResponse> updateUserProfile(
    String userId,
    UserProfileUpdateRequest request,
  );

  Future<String> updateUserAvatar(String userId, File avatar);

  Future<void> removeUserAvatar(String userId);
}
