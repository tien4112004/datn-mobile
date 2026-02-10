import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Internal widget for rendering matching pair content (text, image, or both)
/// Handles all combinations: text-only, image-only, or mixed content
class MatchingContentWidget extends StatelessWidget {
  final String? text;
  final String? imageUrl;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final EdgeInsets? padding;
  final bool isCompact;

  const MatchingContentWidget({
    super.key,
    this.text,
    this.imageUrl,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.isCompact = false,
  });

  bool get hasText => text != null && text!.isNotEmpty;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasBoth => hasText && hasImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If neither text nor image, show placeholder
    if (!hasText && !hasImage) {
      return _buildPlaceholder(theme);
    }

    return Container(
      padding:
          padding ??
          (isCompact ? const EdgeInsets.all(8) : const EdgeInsets.all(12)),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth ?? 1)
            : null,
      ),
      child: hasBoth
          ? _buildMixedContent(theme)
          : (hasImage ? _buildImageOnly(theme) : _buildTextOnly(theme)),
    );
  }

  /// Build text-only content
  Widget _buildTextOnly(ThemeData theme) {
    return Text(
      text!,
      style: isCompact
          ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)
          : theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  /// Build image-only content with proper aspect ratio
  Widget _buildImageOnly(ThemeData theme) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          height: isCompact ? 80 : 180,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: isCompact ? 80 : 180,
            color: theme.colorScheme.surfaceContainerHighest,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: isCompact ? 80 : 180,
            color: theme.colorScheme.errorContainer,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 32,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build mixed content (image + text)
  Widget _buildMixedContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image first
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            height: isCompact ? 80 : 180,
            placeholder: (context, url) => Container(
              height: isCompact ? 80 : 180,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: isCompact ? 80 : 180,
              color: theme.colorScheme.errorContainer,
              child: Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 28,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Text below image
        Text(
          text!,
          style: isCompact
              ? theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)
              : theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }

  /// Build placeholder for empty content
  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.help_outline,
          size: 24,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
