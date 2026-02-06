import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/classes/domain/entity/class_entity.dart';
import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/pods/user_profile_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Google Classroom-style course card widget.
///
/// Displays a colored header section with course title,
/// instructor name, and an options menu.
class ClassCard extends ConsumerWidget {
  final ClassEntity classEntity;
  final VoidCallback? onTap;
  final VoidCallback? onViewStudents;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ClassCard({
    super.key,
    required this.classEntity,
    this.onTap,
    this.onViewStudents,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);
    final instructorName =
        ref.read(userControllerPod).value?.name ?? t.classes.card.instructor;

    return Semantics(
      label: t.classes.card.semanticLabel(className: classEntity.name),
      button: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Themes.boxRadiusValue),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colored header section
              _buildHeader(context, instructorName, t),
              // Content section
              _buildContent(context, colorScheme, t, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String instructorName, dynamic t) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.6),
            classEntity.headerColor.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative pattern
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classEntity.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        classEntity.teacherName,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildOptionsMenu(context, t),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsMenu(BuildContext context, dynamic t) {
    return PopupMenuButton<String>(
      icon: const Icon(
        LucideIcons.ellipsisVertical,
        color: Colors.white,
        size: 20,
      ),
      onSelected: (value) {
        HapticFeedback.selectionClick();
        switch (value) {
          case 'students':
            onViewStudents?.call();
            break;
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (onViewStudents != null)
          PopupMenuItem(
            value: 'students',
            child: Row(
              children: [
                const Icon(LucideIcons.users, size: 18),
                const SizedBox(width: 12),
                Text(t.classes.card.viewStudents),
              ],
            ),
          ),
        if (onEdit != null)
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                const Icon(LucideIcons.pencil, size: 18),
                const SizedBox(width: 12),
                Text(t.classes.card.edit),
              ],
            ),
          ),
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(LucideIcons.trash2, size: 18),
                const SizedBox(width: 12),
                Text(t.classes.card.delete),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    ColorScheme colorScheme,
    dynamic t,
    WidgetRef ref,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: classEntity.isActive
                  ? colorScheme.primaryContainer
                  : colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  classEntity.isActive
                      ? LucideIcons.circleCheck
                      : LucideIcons.circleX,
                  size: 14,
                  color: classEntity.isActive
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  classEntity.isActive
                      ? t.classes.card.active
                      : t.classes.card.inactive,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: classEntity.isActive
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Created date
          if (classEntity.createdAt != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormatHelper.formatRelativeDate(
                    classEntity.createdAt!,
                    ref: ref,
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
