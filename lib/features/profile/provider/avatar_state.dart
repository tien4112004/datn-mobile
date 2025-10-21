part of 'avatar_provider.dart';

class AvatarState {
  final String? avatarUrl;
  final File? localAvatarFile;
  final bool isLoading;
  final String? error;

  const AvatarState({
    this.avatarUrl,
    this.localAvatarFile,
    this.isLoading = false,
    this.error,
  });

  AvatarState copyWith({
    String? avatarUrl,
    File? localAvatarFile,
    bool? isLoading,
    String? error,
  }) {
    return AvatarState(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      localAvatarFile: localAvatarFile ?? this.localAvatarFile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
