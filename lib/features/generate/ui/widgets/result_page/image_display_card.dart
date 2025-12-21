import 'package:cached_network_image/cached_network_image.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays the generated image with loading and error states
class ImageDisplayCard extends ConsumerWidget {
  final String? imageUrl;
  final bool isLoading;
  final VoidCallback? onRetry;

  const ImageDisplayCard({
    super.key,
    this.imageUrl,
    this.isLoading = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    // Loading state
    if (isLoading) {
      return _buildLoadingState(context, t);
    }

    // No image state
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildNoImageState(context, t);
    }

    // Image display state
    return GestureDetector(
      onTap: () {
        if (imageUrl != null) {
          _showFullScreenImage(context, imageUrl!);
        }
      },
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: context.isDarkMode ? Colors.grey[800] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 300,
              color: context.isDarkMode ? Colors.grey[800] : Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) =>
                _buildImageErrorState(context, t),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.white, size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, Translations t) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: context.isDarkMode ? Colors.grey[800] : Colors.grey[200],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(cs.primary),
            ),
            const SizedBox(height: 16),
            Text(
              t.generate.imageResult.generatingImage,
              style: TextStyle(fontSize: 14, color: context.secondaryTextColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoImageState(BuildContext context, Translations t) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: context.isDarkMode ? Colors.grey[800] : Colors.grey[100],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 64,
              color: context.secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              t.generate.imageResult.noImageGenerated,
              style: TextStyle(fontSize: 14, color: context.secondaryTextColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageErrorState(BuildContext context, Translations t) {
    return Container(
      height: 300,
      color: context.isDarkMode ? Colors.grey[800] : Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 48,
              color: context.secondaryTextColor,
            ),
            const SizedBox(height: 8),
            Text(
              t.generate.imageResult.failedToLoadImage,
              style: TextStyle(color: context.secondaryTextColor),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
