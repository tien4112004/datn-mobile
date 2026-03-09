import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/thumbnail.dart';
import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
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
    this.grade,
    this.subject,
  });

  final String title;
  final String? description;
  final String? thumbnail;
  final DateTime? updatedAt;
  final VoidCallback? onTap;
  final VoidCallback? onMoreOptions;
  final ResourceType resourceType;
  final String? grade;
  final String? subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final colorScheme = Theme.of(context).colorScheme;

    final gradeEnum = grade != null ? GradeLevel.fromApiValue(grade!) : null;
    final subjectEnum = subject != null ? Subject.fromApiValue(subject!) : null;
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
                    title.isEmpty ? t.projects.untitled : title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (gradeEnum != null || subjectEnum != null) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (gradeEnum != null)
                          _MetadataLabel(
                            label: gradeEnum.getLocalizedName(t),
                            color: colorScheme.primaryContainer,
                            textColor: colorScheme.onPrimaryContainer,
                          ),
                        if (subjectEnum != null)
                          _MetadataLabel(
                            label: subjectEnum.getLocalizedName(t),
                            color: colorScheme.secondaryContainer,
                            textColor: colorScheme.onSecondaryContainer,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
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
              tooltip: t.students.tile.moreActions,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataLabel extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _MetadataLabel({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
