import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:datn_mobile/features/projects/ui/widgets/common/presentation_thumbnail.dart';

class PresentationListItem extends ConsumerWidget {
  final dynamic presentation;

  const PresentationListItem({super.key, required this.presentation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    return InkWell(
      onTap: () {
        // TODO: Navigate to presentation detail
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.projects.opening(
                title: presentation.title ?? t.projects.untitled,
              ),
            ),
          ),
        );
      },
      borderRadius: Themes.boxRadius,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: Themes.boxRadius,
        ),
        child: Row(
          children: [
            // Thumbnail
            presentation.thumbnail != null
                ? PresentationThumbnail(
                    slide: presentation.thumbnail!,
                    width: 120,
                    height: 120 * 9 / 16,
                    borderRadius: 8,
                    showLoadingIndicator: false,
                  )
                : Container(
                    width: 120,
                    height: 120 * 9 / 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        LucideIcons.presentation,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 32,
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
                    presentation.title ?? t.projects.untitled,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(presentation.updatedAt, t),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            // More options
            IconButton(
              icon: const Icon(LucideIcons.ellipsisVertical),
              onPressed: () {
                // TODO: Show options menu
              },
            ),
          ],
        ),
      ),
    );
  }

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
}
