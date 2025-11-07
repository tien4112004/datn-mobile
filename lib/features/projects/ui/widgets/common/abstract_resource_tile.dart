import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/domain/entity/value_object/slide.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:datn_mobile/features/projects/ui/widgets/common/thumbnail.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
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
  final Slide? thumbnail;
  final DateTime? updatedAt;
  final VoidCallback? onTap;
  final VoidCallback? onMoreOptions;
  final ResourceType resourceType;

  String _formatDate(DateTime? date, dynamic t) {
    if (date == null) return t.projects.unknown_date;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return t.projects.minutes_ago(count: difference.inMinutes);
      }
      return t.projects.hours_ago(count: difference.inHours);
    } else if (difference.inDays == 1) {
      return t.projects.yesterday;
    } else if (difference.inDays < 7) {
      return t.projects.days_ago(count: difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _parseColor(String colorString) {
    try {
      final hexColor = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

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
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: thumbnail?.background.color != null
                    ? _parseColor(thumbnail!.background.color)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: thumbnail == null
                  ? Center(
                      child: Icon(
                        resourceType.lucideIcon,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 32,
                      ),
                    )
                  : const Thumbnail(),
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
                  const SizedBox(height: 4),
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
                    const SizedBox(height: 4),
                  ],
                  Text(
                    _formatDate(updatedAt, t),
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
