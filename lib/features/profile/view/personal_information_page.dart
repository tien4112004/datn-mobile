import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/auth/controllers/user_controller.dart';
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
    final user = await ref.read(userControllerProvider.future);
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

  Future<bool> _requestPermission() async {
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
      if (mounted) {
        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'Gallery access is required to select photos. Please grant permission in settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open Settings'),
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

    setState(() => _isLoading = true);

    try {
      final user = await ref.read(userControllerProvider.future);
      final userId = user?.email ?? '';

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
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
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
    try {
      // Check and request permission
      final hasPermission = await _requestPermission();

      if (!hasPermission) return;

      // Permission granted, open image picker
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        // Update avatar with the selected image
        await ref.read(avatarProvider.notifier).updateAvatar(image.path);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avatar updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload avatar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeAvatar() async {
    try {
      // Clear the avatar from avatar provider
      await ref.read(avatarProvider.notifier).clearAvatar();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove avatar: $e'),
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
            return const Center(child: Text('No profile data'));
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
                                      child: const Row(
                                        children: [
                                          Icon(LucideIcons.upload),
                                          SizedBox(width: 12),
                                          Text('Upload Photo'),
                                        ],
                                      ),
                                    ),
                                    if (hasAvatar)
                                      PopupMenuItem(
                                        onTap: _removeAvatar,
                                        child: const Row(
                                          children: [
                                            Icon(
                                              LucideIcons.trash2,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Remove Photo',
                                              style: TextStyle(
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
                    'Personal Information',
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
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(LucideIcons.user),
                      border: OutlineInputBorder(
                        borderRadius: Themes.boxRadius,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Last Name
                  TextFormField(
                    controller: _lastNameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(LucideIcons.user),
                      border: OutlineInputBorder(
                        borderRadius: Themes.boxRadius,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
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
                      labelText: 'Email',
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
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(LucideIcons.phone),
                      border: OutlineInputBorder(
                        borderRadius: Themes.boxRadius,
                      ),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
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
                        labelText: 'Date of Birth',
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
                            : 'Select date',
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
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
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
                'Error loading profile',
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
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
