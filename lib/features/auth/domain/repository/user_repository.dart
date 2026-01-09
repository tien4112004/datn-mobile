import 'dart:io';

import 'package:datn_mobile/features/auth/data/dto/request/user_profile_update_request.dart';
import 'package:datn_mobile/features/auth/data/dto/response/user_profile_response.dart';
import 'package:datn_mobile/features/auth/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile> getCurrentUser();
  Future<UserProfile?> getCachedUser();
  Future<void> saveCachedUser(UserProfile profile);
  Future<void> clearCachedUser();
}
