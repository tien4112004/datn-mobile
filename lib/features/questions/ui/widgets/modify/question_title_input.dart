import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/services/media_service_provider.dart';

class QuestionTitleInput extends ConsumerStatefulWidget {
  final String title;
  final ValueChanged<String> onTitleChanged;
  final String? titleImageUrl;
  final ValueChanged<String?> onTitleImageChanged;

  const QuestionTitleInput({
    super.key,
    required this.title,
    required this.onTitleChanged,
    this.titleImageUrl,
    required this.onTitleImageChanged,
  });

  @override
  ConsumerState<QuestionTitleInput> createState() => _QuestionTitleInputState();
}

class _QuestionTitleInputState extends ConsumerState<QuestionTitleInput> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final t = ref.read(translationsPod);
    try {
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        setState(() => _isUploading = true);
        try {
          final mediaService = ref.read(mediaServiceProvider);
          final response = await mediaService.uploadMedia(filePath: image.path);
          if (mounted) {
            setState(() => _isUploading = false);
            widget.onTitleImageChanged(response.cdnUrl);
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isUploading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(t.common.failedToUpload(error: e.toString())),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.common.failedToPick(error: e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showUrlDialog() async {
    final t = ref.read(translationsPod);
    final urlController = TextEditingController(text: widget.titleImageUrl);
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
              Text(t.common.enterImageUrl),
            ],
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: t.common.imageUrlLabel,
                hintText: t.projects.images.search_images,
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasScheme) {
                    return t.common.invalidUrl;
                  }
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.common.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, urlController.text.trim());
                }
              },
              child: Text(t.common.add),
            ),
          ],
        );
      },
    );

    if (result != null) {
      widget.onTitleImageChanged(result.isEmpty ? null : result);
    }

    urlController.dispose();
  }

  void _showSourceDialog() {
    final t = ref.read(translationsPod);
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
                  t.questionBank.form.selectImage,
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
                  title: Text(t.common.chooseFromGallery),
                  subtitle: Text(t.common.selectFromPhotos),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
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
                  title: Text(t.common.takePhoto),
                  subtitle: Text(t.common.useCamera),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
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
                  title: Text(t.common.enterImageUrl),
                  subtitle: Text(t.common.pasteLink),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            TextFormField(
              initialValue: widget.title,
              onChanged: widget.onTitleChanged,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: t.questionBank.form.titleHint,
                hintStyle: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(
                  right: 48,
                ), // Space for image button
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return t.questionBank.form.titleRequired;
                }
                return null;
              },
            ),
            // Image button embedded
            IconButton(
              icon: Icon(
                Icons.image_outlined,
                color: widget.titleImageUrl != null
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              onPressed: _isUploading ? null : _showSourceDialog,
              tooltip: t.questionBank.form.addImage,
            ),
          ],
        ),

        // Show uploading indicator
        if (_isUploading) ...[
          const SizedBox(height: 12),
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
                  t.common.loading,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Show selected image if any
        if (!_isUploading && widget.titleImageUrl != null) ...[
          const SizedBox(height: 12),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.titleImageUrl!,
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
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: colorScheme.error,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _showSourceDialog,
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surface.withValues(
                          alpha: 0.9,
                        ),
                        foregroundColor: colorScheme.onSurface,
                      ),
                      tooltip: t.common.edit,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => widget.onTitleImageChanged(null),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.errorContainer,
                        foregroundColor: colorScheme.onErrorContainer,
                      ),
                      tooltip: t.questionBank.form.removeImage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        const Divider(),
      ],
    );
  }
}
