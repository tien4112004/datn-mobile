import 'package:AIPrimary/features/auth/controllers/user_controller.dart';
import 'package:AIPrimary/features/profile/provider/avatar_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePicture extends ConsumerWidget {
  final double size;

  const ProfilePicture({super.key, this.size = 50.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(avatarProvider);
    final userProfileAsync = ref.watch(userControllerProvider);

    final imageProvider = _getImageProvider(avatarState);
    final hasImage = imageProvider != null;

    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: imageProvider,
      backgroundColor: hasImage ? Colors.grey[200] : colorScheme.primary,
      child: avatarState.isLoading
          ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
          : !hasImage
          ? userProfileAsync.maybeWhen(
              data: (profile) => profile != null
                  ? Text(
                      _getInitials(profile.firstName, profile.lastName),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size / 2.5,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
              orElse: () => null,
            )
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

  String _getInitials(String firstName, String lastName) {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }
}
