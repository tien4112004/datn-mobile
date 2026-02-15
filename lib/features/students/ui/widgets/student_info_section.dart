import 'package:AIPrimary/features/students/domain/entity/student.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A section widget displaying student information in read-only mode.
class StudentInfoSection extends ConsumerWidget {
  final Student student;

  const StudentInfoSection({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage:
                      student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                      ? NetworkImage(student.avatarUrl!)
                      : null,
                  child: student.avatarUrl == null || student.avatarUrl!.isEmpty
                      ? Text(
                          _getInitials(student.fullName),
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _InfoRow(
              icon: LucideIcons.phone,
              label: t.students.detail.phone,
              value:
                  (student.phoneNumber != null &&
                      student.phoneNumber!.isNotEmpty)
                  ? student.phoneNumber!
                  : t.students.detail.notAvailable,
            ),
            _InfoRow(
              icon: LucideIcons.mapPin,
              label: t.students.detail.address,
              value: (student.address != null && student.address!.isNotEmpty)
                  ? student.address!
                  : t.students.detail.notAvailable,
            ),
            _InfoRow(
              icon: LucideIcons.calendar,
              label: t.students.detail.enrollmentDate,
              value: _formatDate(student.createdAt),
            ),
            _InfoRow(
              icon: LucideIcons.users,
              label: t.students.detail.parentEmail,
              value:
                  (student.parentContactEmail != null &&
                      student.parentContactEmail!.isNotEmpty)
                  ? student.parentContactEmail!
                  : t.students.detail.notAvailable,
            ),
          ],
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
