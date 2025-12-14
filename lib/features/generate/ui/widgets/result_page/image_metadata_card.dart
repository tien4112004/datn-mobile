import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Displays image metadata in a organized card format
/// Shows: Prompt, Model (if available), Aspect Ratio (if available)
class ImageMetadataCard extends StatelessWidget {
  final String? prompt;
  final String? model;
  final String? aspectRatio;
  final String? mimeType;
  final String? createdDate;

  const ImageMetadataCard({
    super.key,
    this.prompt,
    this.model,
    this.aspectRatio,
    this.mimeType,
    this.createdDate,
  });

  @override
  Widget build(BuildContext context) {
    final metadataFields = <Widget>[];

    // Prompt (primary field)
    if (prompt != null && prompt!.isNotEmpty) {
      metadataFields.add(
        _buildMetadataField(context, label: 'Prompt', value: prompt!),
      );
    }

    // Model
    if (model != null && model!.isNotEmpty) {
      if (metadataFields.isNotEmpty) {
        metadataFields.add(const SizedBox(height: 16));
      }
      metadataFields.add(
        _buildMetadataField(context, label: 'Model', value: model!),
      );
    }

    // Aspect Ratio
    if (aspectRatio != null && aspectRatio!.isNotEmpty) {
      if (metadataFields.isNotEmpty) {
        metadataFields.add(const SizedBox(height: 16));
      }
      metadataFields.add(
        _buildMetadataField(
          context,
          label: 'Aspect Ratio',
          value: aspectRatio!,
        ),
      );
    }

    // Secondary fields (Format, Created Date)
    final hasSecondary =
        (mimeType != null && mimeType!.isNotEmpty) ||
        (createdDate != null && createdDate!.isNotEmpty);

    if (hasSecondary && metadataFields.isNotEmpty) {
      metadataFields.add(const SizedBox(height: 16));
      metadataFields.add(
        Divider(
          color: context.isDarkMode ? Colors.grey[700] : Colors.grey[200],
          height: 1,
        ),
      );
      metadataFields.add(const SizedBox(height: 16));
    }

    // Format/MIME Type
    if (mimeType != null && mimeType!.isNotEmpty) {
      metadataFields.add(
        _buildMetadataField(
          context,
          label: 'Format',
          value: mimeType!,
          isSmall: true,
        ),
      );
      if (createdDate != null && createdDate!.isNotEmpty) {
        metadataFields.add(const SizedBox(height: 12));
      }
    }

    // Created Date
    if (createdDate != null && createdDate!.isNotEmpty) {
      metadataFields.add(
        _buildMetadataField(
          context,
          label: 'Created',
          value: createdDate!,
          isSmall: true,
        ),
      );
    }

    // If no metadata, show empty state
    if (metadataFields.isEmpty) {
      return const SizedBox.shrink();
    }

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
        children: metadataFields,
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
}
