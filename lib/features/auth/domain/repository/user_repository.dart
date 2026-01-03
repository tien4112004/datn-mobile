import 'package:datn_mobile/features/auth/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile> getCurrentUser();
  Future<UserProfile?> getCachedUser();
  Future<void> saveCachedUser(UserProfile profile);
  Future<void> clearCachedUser();
}
