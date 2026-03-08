import 'package:AIPrimary/features/classes/data/dto/post_response_dto.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget to display attachments in a post
class PostAttachmentsDisplay extends ConsumerWidget {
  final List<PostAttachmentDto> attachments;

  const PostAttachmentsDisplay({super.key, required this.attachments});

  static const _imageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
    'svg',
  };

  bool _isImage(PostAttachmentDto a) {
    final ext = a.name.split('.').last.toLowerCase();
    return _imageExtensions.contains(ext);
  }

  String _extension(PostAttachmentDto a) {
    final parts = a.name.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : '';
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final images = attachments.where(_isImage).toList();
    final files = attachments.where((a) => !_isImage(a)).toList();

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.paperclip,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                t.classes.posts.attachmentsCount(count: attachments.length),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (images.isNotEmpty) ...[
            _buildImageSection(images, colorScheme),
            if (files.isNotEmpty) const SizedBox(height: 8),
          ],
          if (files.isNotEmpty)
            ...files.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildFileCard(f, theme, colorScheme),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageSection(
    List<PostAttachmentDto> images,
    ColorScheme colorScheme,
  ) {
    if (images.length == 1) {
      return _buildSingleImage(images[0].url, colorScheme);
    } else if (images.length == 2) {
      return Row(
        children: [
          Expanded(child: _buildImageTile(images[0].url, 150, colorScheme)),
          const SizedBox(width: 8),
          Expanded(child: _buildImageTile(images[1].url, 150, colorScheme)),
        ],
      );
    } else if (images.length == 3) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildImageTile(images[0].url, 200, colorScheme),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                _buildImageTile(images[1].url, 96, colorScheme),
                const SizedBox(height: 8),
                _buildImageTile(images[2].url, 96, colorScheme),
              ],
            ),
          ),
        ],
      );
    } else {
      final displayCount = images.length > 4 ? 4 : images.length;
      final remaining = images.length - 4;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.3,
        ),
        itemCount: displayCount,
        itemBuilder: (context, index) {
          final isLast = index == 3 && remaining > 0;
          return Stack(
            children: [
              _buildImageTile(images[index].url, 120, colorScheme),
              if (isLast)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '+$remaining',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }
  }

  Widget _buildFileCard(
    PostAttachmentDto attachment,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final ext = _extension(attachment);
    return GestureDetector(
      onTap: () => _openUrl(attachment.url),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.file,
                color: colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (ext.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ext,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              LucideIcons.externalLink,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleImage(String url, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => _openUrl(url),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          ),
          errorWidget: (context, url, error) => Container(
            color: colorScheme.errorContainer,
            child: Icon(
              LucideIcons.imageOff,
              color: colorScheme.onErrorContainer,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageTile(String url, double height, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => _openUrl(url),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: colorScheme.errorContainer,
            child: Icon(
              LucideIcons.imageOff,
              color: colorScheme.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }
}
