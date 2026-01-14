import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:datn_mobile/features/projects/ui/widgets/common/thumbnail.dart';
import 'package:datn_mobile/shared/helper/date_format_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ResourceGridCard extends ConsumerWidget {
  const ResourceGridCard({
    super.key,
    required this.title,
    this.description,
    this.updatedAt,
    this.thumbnail,
    this.onTap,
    this.onMoreOptions,
    required this.resourceType,
  });

  final String title;
  final String? description;
  final String? thumbnail;
  final DateTime? updatedAt;
  final VoidCallback? onTap;
  final VoidCallback? onMoreOptions;
  final ResourceType resourceType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      borderRadius: Themes.boxRadius,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: Themes.boxRadius,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  color: resourceType.color.withValues(alpha: 0.1),
                  child: Center(
                    child: thumbnail == null
                        ? DefaultThumbnail(resourceType: resourceType)
                        : _isImageUrl(thumbnail!)
                        ? Image.network(
                            thumbnail!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Icon(
                            resourceType.icon,
                            size: 48,
                            color: resourceType.color,
                          ),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onMoreOptions != null)
                        GestureDetector(
                          onTap: onMoreOptions,
                          child: const Icon(
                            LucideIcons.ellipsisVertical,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (description != null) ...[
                    Text(
                      description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    DateFormatHelper.formatRelativeDate(
                      ref: ref,
                      updatedAt ?? DateFormatHelper.getNow(),
                    ),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isImageUrl(String url) {
    return url.contains('https://');
  }
}
