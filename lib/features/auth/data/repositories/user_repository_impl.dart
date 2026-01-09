import 'package:datn_mobile/core/secure_storage/secure_storage.dart';
import 'package:datn_mobile/features/auth/data/sources/user_remote_source.dart';
import 'package:datn_mobile/features/auth/domain/entities/user_profile.dart';
import 'package:datn_mobile/features/auth/domain/entities/user_role.dart';
import 'package:datn_mobile/features/auth/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteSource _remoteSource;
  final SecureStorage _secureStorage;

  UserRepositoryImpl(this._remoteSource, this._secureStorage);

  @override
  Future<UserProfile> getCurrentUser() async {
    final response = await _remoteSource.getCurrentUser();
    final dto = response.data!;
    final profile = UserProfile(
      email: dto.email,
      firstName: dto.firstName,
      lastName: dto.lastName,
      dateOfBirth: dto.dateOfBirth ?? DateTime(1970, 1, 1),
      phoneNumber: dto.phoneNumber ?? '',
      role: UserRole.fromString(dto.role),
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
}
