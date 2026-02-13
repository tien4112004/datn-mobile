import 'package:AIPrimary/const/resource.dart';
import 'package:AIPrimary/core/local_storage/app_storage_pod.dart';
import 'package:AIPrimary/core/secure_storage/secure_storage_pod.dart';
import 'package:AIPrimary/features/auth/data/repositories/user_repository_provider.dart';
import 'package:AIPrimary/features/auth/domain/entities/user_profile.dart';
import 'package:AIPrimary/features/auth/domain/entities/user_role.dart';
import 'package:AIPrimary/features/classes/states/controller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_pod.freezed.dart';

final userControllerPod = AsyncNotifierProvider<UserController, UserState?>(
  UserController.new,
);

final userRolePod = Provider<UserRole?>((ref) {
  return ref.watch(userControllerPod).value?.role;
});

@freezed
abstract class UserState with _$UserState {
  const factory UserState({
    required String id,
    required String name,
    String? email,
    String? avatarUrl,
    UserRole? role,
  }) = _UserState;

  factory UserState.fromUserProfile(UserProfile profile) {
    return UserState(
      id: profile.id,
      email: profile.email,
      name: profile.fullName,
      avatarUrl: null,
      role: profile.role,
    );
  }
}

class UserController extends AsyncNotifier<UserState?> {
  @override
  Future<UserState?> build() async {
    // Try to get from local storage first
    final cachedProfile = await _getUserProfileFromStorage();
    if (cachedProfile != null) {
      return UserState.fromUserProfile(cachedProfile);
    }

    // If not in storage, fetch from API
    if (await ref.read(secureStoragePod).containsKey(R.ACCESS_TOKEN_KEY)) {
      return await fetchAndStoreUserProfile();
    }

    return null;
  }

  /// Fetch user profile from API and store to local storage
  Future<UserState> fetchAndStoreUserProfile() async {
    final repository = ref.read(userRepositoryProvider);
    final profile = await repository.getCurrentUser();

    debugPrint('User profile fetched from API: $profile');

    // Store to local storage
    await _saveUserProfileToStorage(profile);

    if (profile.role == UserRole.student) {
      ref.read(classesControllerProvider.notifier).refresh();
    }

    return UserState.fromUserProfile(profile);
  }

  /// Update user profile with new data
  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // Update in local storage
      await _saveUserProfileToStorage(updatedProfile);

      return UserState.fromUserProfile(updatedProfile);
    });
  }

  /// Refresh user profile from API
  Future<void> refreshUserProfile() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      debugPrint('Refreshing user profile...');
      return await fetchAndStoreUserProfile();
    });
  }

  /// Get user profile from local storage
  Future<UserProfile?> _getUserProfileFromStorage() async {
    try {
      final storage = ref.read(appStorageProvider);
      final json = storage.getJson(key: R.USER_PROFILE_KEY);

      if (json != null) {
        return UserProfile.fromJson(json);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Save user profile to local storage
  Future<void> _saveUserProfileToStorage(UserProfile profile) async {
    try {
      final storage = ref.read(appStorageProvider);
      await storage.putJson(key: R.USER_PROFILE_KEY, value: profile.toJson());
    } catch (e) {
      // Log error but don't throw - storage failure shouldn't break the app
      // print('Failed to save user profile to storage: $e');
    }
  }
}
