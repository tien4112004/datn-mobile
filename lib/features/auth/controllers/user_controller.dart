import 'package:datn_mobile/features/auth/controllers/auth_controller_pod.dart';
import 'package:datn_mobile/features/auth/data/repositories/user_repository_provider.dart';
import 'package:datn_mobile/features/auth/domain/entities/user_profile.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userControllerProvider =
    AsyncNotifierProvider<UserController, UserProfile?>(() => UserController());

class UserController extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final authState = ref.watch(authControllerPod);

    // If not authenticated, clear cache and return null
    if (authState.value?.isAuthenticated != true) {
      await _clearCachedUser();
      return null;
    }

    // If authenticated, try to load from cache first
    final cachedUser = await _loadCachedUser();
    if (cachedUser != null) {
      debugPrint("Loaded user from cache: ${cachedUser.email}");
      return cachedUser;
    }

    // If no cache, fetch from API
    debugPrint("No cached user found, fetching from API");
    return _fetchUser();
  }

  // Set role for the current user
  // NOTE: TEST ONLY
  void setUserRole(String role) {
    debugPrint("Setting user role to: $role");
    state = const AsyncLoading();
    final currentUser = state.value;
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(role: role);
      debugPrint("Updated user before role change: ${updatedUser.toJson()}");
      state = AsyncData(updatedUser);
    }
  }

  bool isStudent() {
    final currentUser = state.value;
    return currentUser?.role == 'student';
  }

  // Force refresh user from API
  Future<void> refreshUser() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchUser());
  }

  Future<UserProfile?> _loadCachedUser() async {
    final repository = ref.read(userRepositoryProvider);
    return await repository.getCachedUser();
  }

  Future<UserProfile?> _fetchUser() async {
    final repository = ref.read(userRepositoryProvider);
    return await repository.getCurrentUser();
  }

  Future<void> _clearCachedUser() async {
    final repository = ref.read(userRepositoryProvider);
    await repository.clearCachedUser();
  }
}
