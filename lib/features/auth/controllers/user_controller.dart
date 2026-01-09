import 'package:datn_mobile/const/resource.dart';
import 'package:datn_mobile/core/local_storage/app_storage_pod.dart';
import 'package:datn_mobile/core/secure_storage/secure_storage_pod.dart';
import 'package:datn_mobile/features/auth/data/repositories/user_repository_provider.dart';
import 'package:datn_mobile/features/auth/domain/entities/user_profile.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userControllerProvider =
    AsyncNotifierProvider<UserController, UserProfile?>(() => UserController());

class UserController extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    // Try to get from local storage first
    final cachedProfile = await _getUserProfileFromStorage();
    if (cachedProfile != null) {
      return cachedProfile;
    }

    // If not in storage, fetch from API
    if (await ref.read(secureStoragePod).containsKey(R.ACCESS_TOKEN_KEY)) {
      return await fetchAndStoreUserProfile();
    }

    return null;
  }

  /// Fetch user profile from API and store to local storage
  Future<UserProfile> fetchAndStoreUserProfile() async {
    final repository = ref.read(userRepositoryProvider);
    final profile = await repository.getCurrentUser();

    debugPrint('User profile fetched from API: $profile');

    // Store to local storage
    await _saveUserProfileToStorage(profile);

    return profile;
  }

  /// Update user profile with new data
  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // Update in local storage
      await _saveUserProfileToStorage(updatedProfile);

      return updatedProfile;
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

  bool get isStudent => state.value?.role == 'student';

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

  // Future<void> _clearCachedUser() async {
  //   final repository = ref.read(userRepositoryProvider);
  //   await repository.clearCachedUser();
  // }
}
