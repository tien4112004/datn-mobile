import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/thumbnail.dart';
import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AbstractResourceTile extends ConsumerWidget {
  const AbstractResourceTile({
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
    debugPrint('Building AbstractResourceTile for $title');
    return InkWell(
      onTap: onTap,
      borderRadius: Themes.boxRadius,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(borderRadius: Themes.boxRadius),
        child: Row(
          children: [
            // Thumbnail
            Container(
              constraints: const BoxConstraints(
                minWidth: 100,
                minHeight: 64,
                maxWidth: 120,
                maxHeight: 80,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: resourceType.color.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                clipBehavior: Clip.hardEdge,
                child: Center(
                  child: thumbnail == null
                      ? DefaultThumbnail(resourceType: resourceType)
                      : Image.network(
                          thumbnail!,
                          fit: BoxFit.fitHeight,
                          cacheWidth: 200,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Title and metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (description != null) ...[
                    Text(
                      description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
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
            // More options
            IconButton(
              icon: const Icon(LucideIcons.ellipsisVertical),
              onPressed: onMoreOptions,
            ),
          ],
        ),
      ),
    );
  }
}
