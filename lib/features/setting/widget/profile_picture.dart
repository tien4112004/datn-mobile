import 'package:datn_mobile/features/profile/provider/avatar_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePicture extends ConsumerWidget {
  final double size;

  const ProfilePicture({super.key, this.size = 50.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(avatarProvider);

    return CircleAvatar(
      radius: size / 2,
      backgroundImage: _getImageProvider(avatarState),
      backgroundColor: Colors.grey[200],
      child: avatarState.isLoading
          ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
          : null,
    );
  }

  ImageProvider? _getImageProvider(AvatarState state) {
    if (state.localAvatarFile != null) {
      return FileImage(state.localAvatarFile!);
    } else if (state.avatarUrl != null) {
      return NetworkImage(state.avatarUrl!);
    }
    return null;
  }
}
