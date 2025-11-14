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
import 'package:shadcn_ui/shadcn_ui.dart';

class SettingProfilePicture extends ConsumerWidget {
  const SettingProfilePicture({super.key});

  Future<Permission> _getRequiredPermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // For Android 13+ (API 33+), use photos permission
      if (androidInfo.version.sdkInt >= 33) {
        return Permission.photos;
      }
      // For Android 12 and below, use storage permission
      else {
        return Permission.storage;
      }
    }
    // For iOS
    return Permission.photos;
  }

  Future<bool> _requestPermission(BuildContext context, WidgetRef ref) async {
    final t = ref.read(translationsPod);
    final permission = await _getRequiredPermission();

    // Check current status
    var status = await permission.status;

    // If already granted, return true
    if (status.isGranted) {
      return true;
    }

    // If denied but not permanently, request permission
    if (status.isDenied) {
      status = await permission.request();
    }

    // If still denied after request or permanently denied, show dialog
    if (status.isDenied || status.isPermanentlyDenied) {
      if (context.mounted) {
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
          await openAppSettings();
        }
      }
      return false;
    }

    return status.isGranted;
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    try {
      // Check and request permission
      final hasPermission = await _requestPermission(context, ref);

      if (!hasPermission) return;

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
            content: Text(t.profile.avatarUpdateFailed(error: e)),
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
