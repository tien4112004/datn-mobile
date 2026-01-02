import 'package:datn_mobile/features/auth/controllers/auth_controller_pod.dart';
import 'package:datn_mobile/features/auth/data/repositories/user_repository_provider.dart';
import 'package:datn_mobile/features/auth/domain/entities/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userControllerProvider =
    AsyncNotifierProvider<UserController, UserProfile?>(() => UserController());

class UserController extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final authState = ref.watch(authControllerPod);

    // If authenticated, fetch user profile
    if (authState.value?.isAuthenticated == true) {
      return _fetchUser();
    }

    // If not authenticated, return null
    return null;
  }

  Future<UserProfile?> _fetchUser() async {
    final repository = ref.read(userRepositoryProvider);
    return await repository.getCurrentUser();
  }
}
