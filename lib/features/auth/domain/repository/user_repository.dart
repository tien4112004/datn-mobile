import 'package:datn_mobile/features/auth/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile> getCurrentUser();
}
