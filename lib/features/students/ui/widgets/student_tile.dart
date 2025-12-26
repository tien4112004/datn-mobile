import 'package:datn_mobile/features/students/domain/entity/student.dart';
import 'package:datn_mobile/features/students/enum/student_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A list tile widget displaying student information with accessibility support.
class StudentTile extends StatelessWidget {
  final Student student;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StudentTile({
    super.key,
    required this.student,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Create semantic label for screen readers
    final semanticLabel =
        'Student: ${student.fullName}, Email: ${student.email}, Status: ${student.status.label}';

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: true,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: onTap != null
              ? () {
                  HapticFeedback.lightImpact();
                  onTap?.call();
                }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar with Hero animation for smooth transitions
                Hero(
                  tag: 'student_avatar_${student.id}',
                  child: Semantics(
                    label: 'Avatar for ${student.fullName}',
                    image: true,
                    excludeSemantics: true,
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: colorScheme.primaryContainer,
                      backgroundImage:
                          student.avatarUrl != null &&
                              student.avatarUrl!.isNotEmpty
                          ? NetworkImage(student.avatarUrl!)
                          : null,
                      child:
                          student.avatarUrl == null ||
                              student.avatarUrl!.isEmpty
                          ? Text(
                              _getInitials(student.fullName),
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Student info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _StatusBadge(status: student.status),
                    ],
                  ),
                ),
                // Actions menu
                Semantics(
                  label: 'More actions for ${student.fullName}',
                  button: true,
                  hint: 'Double tap to open menu with edit and delete options',
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      LucideIcons.ellipsisVertical,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: 'More actions',
                    onSelected: (value) {
                      HapticFeedback.mediumImpact();
                      if (value == 'edit') {
                        onEdit?.call();
                      } else if (value == 'delete') {
                        onDelete?.call();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Semantics(
                          label: 'Edit student',
                          button: true,
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.pencil,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              const Text('Edit'),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Semantics(
                          label: 'Delete student',
                          button: true,
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.trash2,
                                size: 18,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Delete',
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _StatusBadge extends StatelessWidget {
  final StudentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(
          color: status.color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
