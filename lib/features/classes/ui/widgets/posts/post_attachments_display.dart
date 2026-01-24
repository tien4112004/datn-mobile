import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget to display attachments in a post
class PostAttachmentsDisplay extends StatelessWidget {
  final List<String> attachments;

  const PostAttachmentsDisplay({super.key, required this.attachments});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                '${attachments.length} attachment${attachments.length > 1 ? 's' : ''}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (attachments.length == 1)
            _buildSingleImage(attachments[0], colorScheme)
          else if (attachments.length == 2)
            _buildTwoImages(colorScheme)
          else if (attachments.length == 3)
            _buildThreeImages(colorScheme)
          else
            _buildGrid(colorScheme),
        ],
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

  Widget _buildTwoImages(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(child: _buildImageTile(attachments[0], 150, colorScheme)),
        const SizedBox(width: 8),
        Expanded(child: _buildImageTile(attachments[1], 150, colorScheme)),
      ],
    );
  }

  Widget _buildThreeImages(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildImageTile(attachments[0], 200, colorScheme),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              _buildImageTile(attachments[1], 96, colorScheme),
              const SizedBox(height: 8),
              _buildImageTile(attachments[2], 96, colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(ColorScheme colorScheme) {
    final displayCount = attachments.length > 4 ? 4 : attachments.length;
    final remaining = attachments.length - 4;

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
            _buildImageTile(attachments[index], 120, colorScheme),
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
