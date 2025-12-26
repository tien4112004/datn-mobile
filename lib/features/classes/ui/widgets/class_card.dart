import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/classes/domain/entity/class_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Google Classroom-style course card widget.
///
/// Displays a colored header section with course title,
/// instructor name, and an options menu.
class ClassCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'Class card for ${classEntity.name}',
      button: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: const RoundedRectangleBorder(borderRadius: Themes.boxRadius),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colored header section
              _buildHeader(context),
              // Content section
              _buildContent(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
                  classEntity.displayInstructorName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildOptionsMenu(context),
        ],
      ),
    );
  }

  Widget _buildOptionsMenu(BuildContext context) {
    return Semantics(
      label: 'More options for ${classEntity.name}',
      button: true,
      child: PopupMenuButton<String>(
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
          const PopupMenuItem(
            value: 'students',
            child: Row(
              children: [
                Icon(LucideIcons.users, size: 18),
                SizedBox(width: 12),
                Text('View Students'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(LucideIcons.pencil, size: 18),
                SizedBox(width: 12),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(LucideIcons.trash2, size: 18),
                SizedBox(width: 12),
                Text('Delete'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Join code chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.key,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  classEntity.joinCode ?? 'Create join code',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Status indicator
          if (!classEntity.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Inactive',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
