part of 'avatar_provider.dart';

class AvatarNotifier extends Notifier<AvatarState> {
  @override
  AvatarState build() {
    return const AvatarState(
      avatarUrl:
          "https://claritycareconsulting.co.uk/wp-content/uploads/et_temp/Blank-Profile-Picture-34126_1080x675.jpg",
    );
  }

  Future<void> updateAvatar(String imagePath) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profileService = ref.read(profileServiceProvider);
      // Call the mocked service
      final uploadedUrl = await profileService.updateAvatar(imagePath);

      // Update state with the new image
      state = state.copyWith(
        localAvatarFile: File(imagePath),
        avatarUrl: uploadedUrl,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
