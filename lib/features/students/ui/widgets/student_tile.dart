import 'package:datn_mobile/features/students/domain/entity/student.dart';
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
        'Student: ${student.fullName}, Email: ${student.parentContactEmail}';

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: true,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        child: InkWell(
          onTap: onTap != null
              ? () {
                  HapticFeedback.lightImpact();
                  onTap?.call();
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Enhanced avatar with gradient ring
                Hero(
                  tag: 'student_avatar_${student.id}',
                  child: Semantics(
                    label: 'Avatar for ${student.fullName}',
                    image: true,
                    excludeSemantics: true,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colorScheme.primary, colorScheme.secondary],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(2.5),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: colorScheme.surfaceContainerHighest,
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
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Student info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Row(
                      //   children: [
                      //     Icon(
                      //       LucideIcons.mail,
                      //       size: 14,
                      //       color: colorScheme.onSurfaceVariant,
                      //     ),
                      //     const SizedBox(width: 6),
                      //     Expanded(
                      //       child: Text(
                      //         student.,
                      //         style: theme.textTheme.bodySmall?.copyWith(
                      //           color: colorScheme.onSurfaceVariant,
                      //         ),
                      //         overflow: TextOverflow.ellipsis,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Enhanced actions menu
                Semantics(
                  label: 'More actions for ${student.fullName}',
                  button: true,
                  hint: 'Double tap to open menu with edit and delete options',
                  child: PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.ellipsisVertical,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    tooltip: 'More actions',
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
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
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  LucideIcons.pencil,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text('Edit'),
                            ],
                          ),
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        child: Semantics(
                          label: 'Delete student',
                          button: true,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  LucideIcons.trash2,
                                  size: 16,
                                  color: colorScheme.error,
                                ),
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
