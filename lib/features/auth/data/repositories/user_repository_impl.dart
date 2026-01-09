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
      email: dto.email,
      firstName: dto.firstName,
      lastName: dto.lastName,
      dateOfBirth: dto.dateOfBirth,
      phoneNumber: dto.phoneNumber ?? '',
      role: dto.role,
    );
  }
}
