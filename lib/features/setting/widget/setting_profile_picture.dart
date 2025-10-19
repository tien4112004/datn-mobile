import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/features/profile/provider/avatar_provider.dart';
import 'package:datn_mobile/features/setting/widget/profile_picture.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingProfilePicture extends ConsumerWidget {
  const SettingProfilePicture({super.key});

  Future<void> _requestPermission(BuildContext context, WidgetRef ref) async {
    // Request appropriate permission based on Android version
    final t = ref.read(translationsPod);

    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;

    if (android.version.sdkInt >= 33) return;

    final status = await Permission.photos.request();
    if (!status.isPermanentlyDenied && context.mounted) {
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.profile.permissionRequired),
          content: Text(t.profile.permissionMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.profile.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.profile.openSettings),
            ),
          ],
        ),
      );

      if (shouldOpenSettings == true) {
        openAppSettings();
      }
    }

    // if (Platform.isIOS) {
    // } else if (Platform.isAndroid) {}
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    try {
      // Check and request permission
      final status = await Permission.photos.status;

      if (status.isDenied || status.isPermanentlyDenied) {
        if (!context.mounted) return;
        await _requestPermission(context, ref);

        // Check again after requesting
        final newStatus = await Permission.photos.status;
        if (!newStatus.isGranted) {
          return; // User denied permission
        }
      }

      // Permission granted, open image picker
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && context.mounted) {
        // Update avatar with the selected image
        await ref.read(avatarProvider.notifier).updateAvatar(image.path);
        final t = ref.read(translationsPod);

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.profile.avatarUpdatedSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        final t = ref.read(translationsPod);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.profile.avatarUpdateFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const ProfilePicture(size: 100),
        Positioned(
          bottom: 0,
          right: 0,
          height: 32,
          child: InkWell(
            onTap: () => _pickImage(context, ref),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue,
                child: Icon(LucideIcons.pencil, color: Colors.white, size: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
