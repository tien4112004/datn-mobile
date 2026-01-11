import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:datn_mobile/shared/services/media_service_provider.dart';
import 'dart:io';

/// Widget for selecting images either by uploading from device or entering URL
class ImageInputField extends ConsumerStatefulWidget {
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final String label;
  final String hint;
  final bool isRequired;

  const ImageInputField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.label = 'Image',
    this.hint = 'Upload or enter URL',
    this.isRequired = false,
  });

  @override
  ConsumerState<ImageInputField> createState() => _ImageInputFieldState();
}

class _ImageInputFieldState extends ConsumerState<ImageInputField> {
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;
  File? _localImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _imageUrl = widget.initialValue;
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _localImage = File(image.path);
          _imageUrl = null;
          _isUploading = true;
        });

        try {
          // Upload to server and get CDN URL
          final mediaService = ref.read(mediaServiceProvider);
          final response = await mediaService.uploadMedia(filePath: image.path);

          if (mounted) {
            setState(() {
              _imageUrl = response.cdnUrl;
              _localImage = null;
              _isUploading = false;
            });
            widget.onChanged(response.cdnUrl);
          }
        } catch (uploadError) {
          if (mounted) {
            setState(() {
              _localImage = null;
              _isUploading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: $uploadError'),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _localImage = File(image.path);
          _imageUrl = null;
          _isUploading = true;
        });

        try {
          // Upload to server and get CDN URL
          final mediaService = ref.read(mediaServiceProvider);
          final response = await mediaService.uploadMedia(filePath: image.path);

          if (mounted) {
            setState(() {
              _imageUrl = response.cdnUrl;
              _localImage = null;
              _isUploading = false;
            });
            widget.onChanged(response.cdnUrl);
          }
        } catch (uploadError) {
          if (mounted) {
            setState(() {
              _localImage = null;
              _isUploading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: $uploadError'),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showUrlDialog() async {
    final urlController = TextEditingController(text: _imageUrl);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.link, color: colorScheme.primary),
              const SizedBox(width: 12),
              const Text('Enter Image URL'),
            ],
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: 'Image URL',
                hintText: widget.hint,
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
              keyboardType: TextInputType.url,
              validator: (value) {
                if (widget.isRequired &&
                    (value == null || value.trim().isEmpty)) {
                  return 'URL is required';
                }
                if (value != null && value.isNotEmpty) {
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasScheme) {
                    return 'Please enter a valid URL';
                  }
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, urlController.text.trim());
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _imageUrl = result.isEmpty ? null : result;
        _localImage = null;
      });
      widget.onChanged(_imageUrl);
    }

    urlController.dispose();
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Select Image Source',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: const Text('Choose from Gallery'),
                  subtitle: const Text('Select from your photos'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  title: const Text('Take Photo'),
                  subtitle: const Text('Use your camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.link,
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                  title: const Text('Enter Image URL'),
                  subtitle: const Text('Paste a link to an image'),
                  onTap: () {
                    Navigator.pop(context);
                    _showUrlDialog();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _clearImage() {
    setState(() {
      _localImage = null;
      _imageUrl = null;
    });
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasImage = _localImage != null || _imageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label + (widget.isRequired ? ' *' : ' (Optional)'),
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // Show uploading indicator
        if (_isUploading) ...[
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Uploading image...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ] else if (hasImage) ...[
          // Image preview
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _localImage != null
                    ? Image.file(
                        _localImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        _imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.error.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  size: 48,
                                  color: colorScheme.error,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Failed to load image',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // Action buttons overlay
              if (!_isUploading)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _showImageSourceDialog,
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surface.withValues(
                            alpha: 0.9,
                          ),
                          foregroundColor: colorScheme.onSurface,
                        ),
                        tooltip: 'Change image',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _clearImage,
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.errorContainer,
                          foregroundColor: colorScheme.onErrorContainer,
                        ),
                        tooltip: 'Remove image',
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ] else ...[
          // Choose image button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isUploading ? null : _showImageSourceDialog,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Choose Image'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
