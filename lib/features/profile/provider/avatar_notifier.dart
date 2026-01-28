part of 'avatar_provider.dart';

class AvatarNotifier extends Notifier<AvatarState> {
  @override
  AvatarState build() {
    return const AvatarState();
  }

  Future<void> updateAvatar(String imagePath) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profileService = ref.read(profileServiceProvider);
      // Call the mocked service
      await profileService.updateAvatar(imagePath);

      // Update state with the new image
      // Only set localAvatarFile for now since we're not uploading to a server yet
      state = AvatarState(
        localAvatarFile: File(imagePath),
        avatarUrl: null, // Don't set URL for local files
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> clearAvatar() async {
    state = const AvatarState();
  }
}
