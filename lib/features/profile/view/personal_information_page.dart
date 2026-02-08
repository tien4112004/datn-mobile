import 'dart:io';

import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/auth/data/dto/request/user_profile_update_request.dart';
import 'package:AIPrimary/features/profile/controller/profile_controller.dart';
import 'package:AIPrimary/features/profile/provider/avatar_provider.dart';
import 'package:AIPrimary/features/setting/widget/profile_picture.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

@RoutePage()
class PersonalInformationPage extends ConsumerStatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  ConsumerState<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState
    extends ConsumerState<PersonalInformationPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _selectedDateOfBirth;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  Future<void> _loadUserProfile() async {
    final user = await ref.read(userControllerPod.future);
    if (user != null && mounted) {
      await ref
          .read(profileControllerProvider.notifier)
          .loadUserProfile(user.id);

      final profile = ref.read(profileControllerProvider).value;
      if (profile != null && mounted) {
        _firstNameController.text = profile.firstName;
        _lastNameController.text = profile.lastName;
        _phoneNumberController.text = profile.phoneNumber ?? '';
        _emailController.text = profile.email ?? '';
        _selectedDateOfBirth = profile.dateOfBirth;
        setState(() {});
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<Permission> _getRequiredPermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        return Permission.photos;
      } else {
        return Permission.storage;
      }
    }
    return Permission.photos;
  }

  Future<bool> _requestPermission() async {
    final t = ref.read(translationsPod);
    final permission = await _getRequiredPermission();

    var status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      status = await permission.request();
    }

    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(t.profile.permissionRequired),
            content: Text(t.profile.galleryPermissionMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t.common.cancel),
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final t = ref.read(translationsPod);
    setState(() => _isLoading = true);

    try {
      final user = await ref.read(userControllerPod.future);
      final userId = user?.id ?? '';

      final request = UserProfileUpdateRequest(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber: _phoneNumberController.text,
        dateOfBirth: _selectedDateOfBirth,
      );

      await ref
          .read(profileControllerProvider.notifier)
          .updateProfile(userId, request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.profile.updateSuccess),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.profile.updateError(error: e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final t = ref.read(translationsPod);
    try {
      final hasPermission = await _requestPermission();
      if (!hasPermission) return;

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        await ref.read(avatarProvider.notifier).updateAvatar(image.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.profile.avatarUpdateSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.profile.avatarUpdateFailed(error: e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeAvatar() async {
    final t = ref.read(translationsPod);
    try {
      await ref.read(avatarProvider.notifier).clearAvatar();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.profile.avatarRemoveSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.profile.avatarUpdateFailed(error: e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.personalInformation),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(LucideIcons.pencil),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(LucideIcons.x),
              onPressed: () {
                setState(() => _isEditing = false);
                _loadUserProfile();
              },
            ),
        ],
      ),
      body: profileState.when(
        data: (profile) {
          if (profile == null) {
            return Center(child: Text(t.profile.noProfileData));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section
                  Center(
                    child: Stack(
                      children: [
                        const ProfilePicture(size: 120),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Themes.theme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: PopupMenuButton(
                                icon: const Icon(
                                  LucideIcons.camera,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                itemBuilder: (context) {
                                  final avatarState = ref.watch(avatarProvider);
                                  final hasAvatar =
                                      avatarState.localAvatarFile != null ||
                                      avatarState.avatarUrl != null;

                                  return [
                                    PopupMenuItem(
                                      onTap: _pickAndUploadAvatar,
                                      child: Row(
                                        children: [
                                          const Icon(LucideIcons.upload),
                                          const SizedBox(width: 12),
                                          Text(t.profile.uploadPhoto),
                                        ],
                                      ),
                                    ),
                                    if (hasAvatar)
                                      PopupMenuItem(
                                        onTap: _removeAvatar,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              LucideIcons.trash2,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              t.profile.removePhoto,
                                              style: const TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ];
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Personal Information Section
                  Text(
                    t.personalInformation,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Themes.theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // First Name
                  TextFormField(
                    controller: _firstNameController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: t.profile.firstName,
                      prefixIcon: const Icon(LucideIcons.user),
                      border: const OutlineInputBorder(
                        borderRadius: Themes.boxRadius,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.profile.firstNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Last Name
                  TextFormField(
                    controller: _lastNameController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: t.profile.lastName,
                      prefixIcon: const Icon(LucideIcons.user),
                      border: const OutlineInputBorder(
                        borderRadius: Themes.boxRadius,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.profile.lastNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email (Read-only)
                  TextFormField(
                    controller: _emailController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: t.profile.email,
                      prefixIcon: const Icon(LucideIcons.mail),
                      border: const OutlineInputBorder(
                        borderRadius: Themes.boxRadius,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone Number
                  TextFormField(
                    controller: _phoneNumberController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: t.profile.phoneNumber,
                      prefixIcon: const Icon(LucideIcons.phone),
                      border: const OutlineInputBorder(
                        borderRadius: Themes.boxRadius,
                      ),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
                          return t.profile.invalidPhoneNumber;
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth
                  InkWell(
                    onTap: _isEditing ? () => _selectDate(context) : null,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: t.profile.dateOfBirth,
                        prefixIcon: const Icon(LucideIcons.calendar),
                        border: const OutlineInputBorder(
                          borderRadius: Themes.boxRadius,
                        ),
                        enabled: _isEditing,
                      ),
                      child: Text(
                        _selectedDateOfBirth != null
                            ? DateFormat(
                                'yyyy-MM-dd',
                              ).format(_selectedDateOfBirth!)
                            : t.profile.selectDate,
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDateOfBirth != null
                              ? Colors.black87
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Themes.theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: Themes.boxRadius,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                t.profile.saveChanges,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.circleAlert, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                t.profile.errorLoadingProfile,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadUserProfile,
                icon: const Icon(LucideIcons.refreshCw),
                label: Text(t.common.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
