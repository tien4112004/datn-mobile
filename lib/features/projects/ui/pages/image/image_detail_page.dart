import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/projects/domain/entity/image_project.dart';
import 'package:AIPrimary/features/projects/providers/image_detail_provider.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/features/generate/ui/widgets/result_page/image_quick_actions.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/services/service_pod.dart';
import 'package:AIPrimary/shared/utils/format_utils.dart';
import 'package:AIPrimary/shared/widgets/enhanced_error_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:photo_view/photo_view.dart';

@RoutePage()
class ImageDetailPage extends ConsumerWidget {
  final String imageId;

  const ImageDetailPage({
    super.key,
    @PathParam('imageId') required this.imageId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageAsync = ref.watch(imageByIdProvider(imageId));
    final cs = Theme.of(context).colorScheme;
    final t = ref.watch(translationsPod);

    return Scaffold(
      appBar: _buildAppBar(context, ref),
      backgroundColor: cs.surface,
      body: imageAsync.easyWhen(
        data: (image) => Column(
          children: [
            // Single Image with Zoom
            Expanded(
              flex: 3,
              child: _buildZoomableImage(context, image.imageUrl),
            ),

            // Info and Actions Section
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // File Information Card
                    _buildFileInformationCard(context, image, ref),
                    const SizedBox(height: 20),

                    // Quick Actions
                    _buildQuickActions(context, image, ref),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
        errorWidget: (error, stackTrace) => EnhancedErrorState(
          icon: LucideIcons.badgeAlert,
          title: t.projects.images.detail.error_loading,
          message: error.toString(),
          actionLabel: t.projects.images.detail.retry,
          onRetry: () => ref.invalidate(imageByIdProvider(imageId)),
        ),
        loadingWidget: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final t = ref.watch(translationsPod);
    return AppBar(
      title: Row(
        children: [
          Icon(LucideIcons.image, size: 24, color: cs.primary),
          const SizedBox(width: 8),
          Text(t.projects.images.detail.title),
        ],
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: context.isDarkMode ? cs.surface : Colors.white,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft),
        onPressed: () => context.router.back(),
      ),
    );
  }

  Widget _buildZoomableImage(BuildContext context, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.black : Colors.grey[900],
      ),
      child: PhotoView(
        imageProvider: CachedNetworkImageProvider(imageUrl),
        initialScale: PhotoViewComputedScale.contained,
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: PhotoViewComputedScale.covered * 2.5,
        backgroundDecoration: BoxDecoration(
          color: context.isDarkMode ? Colors.black : Colors.grey[900],
        ),
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
          ),
        ),
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(
            LucideIcons.imageOff,
            size: 48,
            color: context.isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildFileInformationCard(BuildContext context, image, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type and Size in a row
          if (image.mediaType != null || image.fileSize != null)
            Row(
              children: [
                if (image.mediaType != null)
                  Expanded(
                    child: _buildMetadataField(
                      context,
                      label: t.projects.images.detail.type,
                      value: formatMediaType(image.mediaType!),
                      isSmall: true,
                    ),
                  ),
                if (image.mediaType != null && image.fileSize != null)
                  const SizedBox(width: 16),
                if (image.fileSize != null)
                  Expanded(
                    child: _buildMetadataField(
                      context,
                      label: t.projects.images.detail.size,
                      value: formatFileSize(image.fileSize!),
                      isSmall: true,
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 16),

          // Created and Updated dates
          Row(
            children: [
              Expanded(
                child: _buildMetadataField(
                  context,
                  label: t.projects.images.created,
                  value: DateFormat('MMM d, yyyy').format(image.createdAt),
                  isSmall: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetadataField(
                  context,
                  label: t.projects.images.updated,
                  value: DateFormat('MMM d, yyyy').format(image.updatedAt),
                  isSmall: true,
                ),
              ),
            ],
          ),

          // Description (if available)
          if (image.description != null && image.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildMetadataField(
              context,
              label: t.projects.images.description,
              value: image.description!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataField(
    BuildContext context, {
    required String label,
    required String value,
    bool isSmall = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 11 : 12,
            fontWeight: FontWeight.w600,
            color: context.tertiaryTextColor,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmall ? 13 : 14,
            fontWeight: FontWeight.w500,
            color: context.isDarkMode ? Colors.white : Colors.grey[800],
            height: 1.4,
          ),
          maxLines: isSmall ? 1 : 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    ImageProject image,
    WidgetRef ref,
  ) {
    return ImageQuickActions(
      onCopyPrompt: () => _copyImageUrl(context, image.imageUrl, ref),
      onShare: () => _shareImage(context, image.imageUrl, image.title, ref),
      onDownload: () =>
          _downloadImage(context, image.imageUrl, image.title, ref),
    );
  }

  Future<void> _shareImage(
    BuildContext context,
    String? url,
    String? title,
    WidgetRef ref,
  ) async {
    if (url == null || url.isEmpty) return;

    final shareService = ref.read(shareServiceProvider);
    final t = ref.read(translationsPod);

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                t.generate.imageResult.downloadImage,
              ), // Using "Downloading..." text
            ],
          ),
          duration: const Duration(seconds: 1),
        ),
      );

      await shareService.shareImage(url: url, prompt: title);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.projects.images.detail.share_failed}: $e'),
          ),
        );
      }
    }
  }

  void _copyImageUrl(BuildContext context, String url, WidgetRef ref) {
    final t = ref.read(translationsPod);
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.projects.images.detail.url_copied)),
    );
  }

  void _downloadImage(
    BuildContext context,
    String url,
    String filename,
    WidgetRef ref,
  ) {
    final downloadService = ref.read(downloadServiceProvider);
    final t = ref.read(translationsPod);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.projects.images.detail.downloading)),
    );

    downloadService
        .downloadImageToGallery(url: url, prompt: filename)
        .listen(
          (progress) {
            // Optional: Handle progress updates
          },
          onDone: () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(t.projects.images.detail.saved)),
              );
            }
          },
          onError: (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${t.projects.images.detail.save_failed}: $error',
                  ),
                ),
              );
            }
          },
        );
  }
}
