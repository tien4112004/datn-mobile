import 'dart:convert';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:flutter/material.dart';

/// A widget that renders a presentation thumbnail from a base64-encoded image string.
///
/// This widget decodes the base64 thumbnail and displays it directly without
/// requiring a WebView or external rendering.
///
/// Example usage:
/// ```dart
/// PresentationThumbnail(
///   thumbnailBase64: base64EncodedString,
///   width: 200,
///   height: 150,
/// )
/// ```
class PresentationThumbnail extends StatelessWidget {
  const PresentationThumbnail({
    super.key,
    this.thumbnailBase64,
    this.width = 200,
    this.height = 150,
  });

  /// The base64-encoded thumbnail image string
  final String? thumbnailBase64;

  /// Width of the thumbnail widget
  final double width;

  /// Height of the thumbnail widget
  final double height;

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'PresentationThumbnail: Building with thumbnail=${thumbnailBase64 != null}, width=$width, height=$height',
    );

    // Show placeholder if no thumbnail provided
    if (thumbnailBase64 == null || thumbnailBase64!.isEmpty) {
      debugPrint(
        'PresentationThumbnail: No thumbnail data provided, showing placeholder.',
      );
      return ClipRRect(
        borderRadius: Themes.boxRadius,
        child: Container(
          width: width,
          height: height,
          color: ResourceType.presentation.color.withValues(alpha: 0.7),
          child: Center(
            child: Icon(
              ResourceType.presentation.icon,
              color: Colors.grey.shade400,
              size: width * 0.4,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: Themes.boxRadius,
      child: Container(
        width: width,
        height: height,
        color: Colors.grey.shade300,
        child: _buildThumbnailImage(),
      ),
    );
  }

  /// Builds the thumbnail image widget from base64 data
  Widget _buildThumbnailImage() {
    try {
      // Decode the base64 string to bytes
      final imageBytes = base64Decode(thumbnailBase64!);

      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error decoding thumbnail image: $error');
          return Center(
            child: Icon(
              Icons.error_outline,
              size: 32,
              color: Colors.grey.shade600,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error processing thumbnail base64: $e');
      return Center(
        child: Icon(Icons.error_outline, size: 32, color: Colors.grey.shade600),
      );
    }
  }
}
