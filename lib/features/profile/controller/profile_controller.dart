import 'dart:async';
import 'dart:io';

import 'package:AIPrimary/features/auth/data/dto/request/user_profile_update_request.dart';
import 'package:AIPrimary/features/auth/data/dto/response/user_profile_response.dart';
import 'package:AIPrimary/features/auth/data/repositories/user_repository_provider.dart';
import 'package:AIPrimary/features/auth/domain/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfileResponse?>(() {
      return ProfileController();
    });

class ProfileController extends AsyncNotifier<UserProfileResponse?> {
  late final UserRepository _userRepository;

  @override
  FutureOr<UserProfileResponse?> build() {
    _userRepository = ref.read(userRepositoryProvider);
    return null;
  }

  Future<void> loadUserProfile(String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _userRepository.getUserProfile(userId),
    );
  }

  Future<void> updateProfile(
    String userId,
    UserProfileUpdateRequest request,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _userRepository.updateUserProfile(userId, request),
    );
  }

  Future<void> updateAvatar(String userId, File avatar) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    state = const AsyncValue.loading();
    try {
      final avatarUrl = await _userRepository.updateUserAvatar(userId, avatar);

      // Update the profile with new avatar URL
      state = AsyncValue.data(
        UserProfileResponse(
          id: currentProfile.id,
          firstName: currentProfile.firstName,
          lastName: currentProfile.lastName,
          email: currentProfile.email,
          phoneNumber: currentProfile.phoneNumber,
          dateOfBirth: currentProfile.dateOfBirth,
          avatarUrl: avatarUrl,
          role: currentProfile.role,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeAvatar(String userId) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    state = const AsyncValue.loading();
    try {
      await _userRepository.removeUserAvatar(userId);

      // Update the profile with null avatar URL
      state = AsyncValue.data(
        UserProfileResponse(
          id: currentProfile.id,
          firstName: currentProfile.firstName,
          lastName: currentProfile.lastName,
          email: currentProfile.email,
          phoneNumber: currentProfile.phoneNumber,
          dateOfBirth: currentProfile.dateOfBirth,
          avatarUrl: null,
          role: currentProfile.role,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
