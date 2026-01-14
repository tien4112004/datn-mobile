import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/providers/image_detail_provider.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:datn_mobile/features/generate/ui/widgets/result_page/image_display_card.dart';
import 'package:datn_mobile/features/generate/ui/widgets/result_page/image_quick_actions.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/services/service_pod.dart';
import 'package:datn_mobile/shared/utils/format_utils.dart';
import 'package:datn_mobile/shared/widget/enhanced_error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: context.isDarkMode
          ? cs.surface
          : const Color(0xFFF9FAFB),
      body: imageAsync.easyWhen(
        data: (image) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Display Card
              ImageDisplayCard(imageUrl: image.imageUrl),
              const SizedBox(height: 28),

              // File Information Card
              _buildFileInformationCard(context, image),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(context, ref, image),
              const SizedBox(height: 20),

              // Back Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.router.back(),
                  icon: const Icon(LucideIcons.arrowLeft),
                  label: const Text('Back to Images'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        errorWidget: (error, stackTrace) => EnhancedErrorState(
          icon: LucideIcons.badgeAlert,
          title: 'Error loading image',
          message: error.toString(),
          actionLabel: 'Retry',
          onRetry: () => ref.invalidate(imageByIdProvider(imageId)),
        ),
        loadingWidget: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      title: Row(
        children: [
          Icon(LucideIcons.image, size: 24, color: cs.primary),
          const SizedBox(width: 8),
          const Text('Image Details'),
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

  Widget _buildFileInformationCard(BuildContext context, image) {
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
          // Filename
          _buildMetadataField(context, label: 'FILENAME', value: image.title),

          if (image.mediaType != null || image.fileSize != null) ...[
            const SizedBox(height: 16),
            Divider(
              color: context.isDarkMode ? Colors.grey[700] : Colors.grey[200],
              height: 1,
            ),
            const SizedBox(height: 16),
          ],

          // Type and Size in a row
          if (image.mediaType != null || image.fileSize != null)
            Row(
              children: [
                if (image.mediaType != null)
                  Expanded(
                    child: _buildMetadataField(
                      context,
                      label: 'TYPE',
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
                      label: 'SIZE',
                      value: formatFileSize(image.fileSize!),
                      isSmall: true,
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 16),
          Divider(
            color: context.isDarkMode ? Colors.grey[700] : Colors.grey[200],
            height: 1,
          ),
          const SizedBox(height: 16),

          // Created and Updated dates
          Row(
            children: [
              Expanded(
                child: _buildMetadataField(
                  context,
                  label: 'CREATED',
                  value: DateFormat('MMM d, yyyy').format(image.createdAt),
                  isSmall: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetadataField(
                  context,
                  label: 'UPDATED',
                  value: DateFormat('MMM d, yyyy').format(image.updatedAt),
                  isSmall: true,
                ),
              ),
            ],
          ),

          // Description (if available)
          if (image.description != null && image.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(
              color: context.isDarkMode ? Colors.grey[700] : Colors.grey[200],
              height: 1,
            ),
            const SizedBox(height: 16),
            _buildMetadataField(
              context,
              label: 'DESCRIPTION',
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

  Widget _buildQuickActions(BuildContext context, WidgetRef ref, image) {
    return ImageQuickActions(
      copyLabel: 'Copy URL',
      onCopyPrompt: () => _copyImageUrl(context, image.imageUrl),
      onShare: () => _shareImage(context, ref, image.imageUrl, image.title),
      onDownload: () =>
          _downloadImage(context, ref, image.imageUrl, image.title),
    );
  }

  Future<void> _shareImage(
    BuildContext context,
    WidgetRef ref,
    String? url,
    String? title,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share image: $e')));
      }
    }
  }

  void _copyImageUrl(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image URL copied to clipboard')),
    );
  }

  void _downloadImage(
    BuildContext context,
    WidgetRef ref,
    String url,
    String filename,
  ) {
    final downloadService = ref.read(downloadServiceProvider);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Downloading image...')));

    downloadService
        .downloadImageToGallery(url: url, prompt: filename)
        .listen(
          (progress) {
            // Optional: Handle progress updates
          },
          onDone: () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image saved to gallery')),
              );
            }
          },
          onError: (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save image: $error')),
              );
            }
          },
        );
  }
}
