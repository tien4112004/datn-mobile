import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/domain/entity/value_object/slide.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:datn_mobile/features/projects/ui/widgets/common/thumbnail.dart';
import 'package:datn_mobile/shared/helper/date_format_helper.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
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
  final Slide? thumbnail;
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
              minHeight: 180,
              minWidth: 140,
              maxWidth: 164,
            ),
            child: Column(
              children: [
                Container(
                  constraints: const BoxConstraints(
                    minHeight: 82,
                    maxHeight: 112,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: Themes.boxRadius,
                    color: resourceType.color.withValues(alpha: 0.1),
                  ),
                  child: thumbnail == null
                      ? DefaultThumbnail(resourceType: resourceType)
                      : const Thumbnail(),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: Themes.fontSize.s16,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
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
                    Text(
                      t.projects.type(type: resourceType.getValue()),
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
