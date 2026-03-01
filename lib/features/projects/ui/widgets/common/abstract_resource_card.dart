import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/thumbnail.dart';
import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AbstractDocumentCard extends ConsumerWidget {
  const AbstractDocumentCard({
    super.key,
    required this.title,
    this.description,
    this.createdAt,
    this.thumbnail,
    this.onTap,
    required this.resourceType,
  });

  final String title;
  final String? description;
  final String? thumbnail;
  final DateTime? createdAt;
  final VoidCallback? onTap;
  final ResourceType resourceType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    return Card(
      shape: const RoundedRectangleBorder(borderRadius: Themes.boxRadius),
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: InkWell(
        borderRadius: Themes.boxRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 100,
              minWidth: 140,
              maxWidth: 164,
            ),
            child: Column(
              children: [
                // Thumbnail
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: Themes.boxRadius,
                      color: resourceType.color.withValues(alpha: 0.1),
                      border: Border.all(
                        color: resourceType.color.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: thumbnail == null
                        ? DefaultThumbnail(resourceType: resourceType)
                        : Thumbnail(imageUrl: thumbnail!),
                  ),
                ),
                SizedBox(height: Themes.padding.p8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title.isEmpty ? t.projects.untitled : title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Themes.fontSize.s16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: Themes.padding.p4),
                    if (description != null) ...[
                      Text(
                        description!,
                        style: TextStyle(
                          fontSize: Themes.fontSize.s12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    // Created at
                    if (createdAt != null) ...[
                      Text(
                        t.projects.edited(
                          date: DateFormatHelper.formatRelativeDate(
                            createdAt!,
                            ref: ref,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: Themes.fontSize.s12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    // Type
                    Text(
                      t.projects.type(type: resourceType.getLabel(t)),
                      style: TextStyle(
                        fontSize: Themes.fontSize.s12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
