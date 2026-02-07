import 'package:AIPrimary/features/classes/domain/entity/class_entity.dart';
import 'package:AIPrimary/features/classes/ui/widgets/edit/class_info_section.dart';
import 'package:AIPrimary/features/classes/ui/widgets/edit/class_settings_section.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Main form widget for editing class information.
///
/// Organizes the edit page into logical sections:
/// - Class information (name, description)
/// - Class settings (active status)
///
/// Implements clean component architecture with separate
/// section widgets for better maintainability.
class ClassEditForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final ClassEntity classEntity;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final bool isActive;
  final VoidCallback onFieldChanged;
  final ValueChanged<bool> onActiveChanged;

  const ClassEditForm({
    super.key,
    required this.formKey,
    required this.classEntity,
    required this.nameController,
    required this.descriptionController,
    required this.isActive,
    required this.onFieldChanged,
    required this.onActiveChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // Class header with color indicator
          _buildClassHeader(context, t),

          const SizedBox(height: 32),

          // Class information section
          ClassInfoSection(
            nameController: nameController,
            descriptionController: descriptionController,
            onFieldChanged: onFieldChanged,
          ),

          const SizedBox(height: 24),

          // Class settings section
          ClassSettingsSection(
            isActive: isActive,
            createdAt: classEntity.createdAt,
            updatedAt: classEntity.updatedAt,
            onActiveChanged: onActiveChanged,
          ),

          const SizedBox(height: 32),

          // Additional info
          _buildMetadataInfo(context, t),
        ],
      ),
    );
  }

  Widget _buildClassHeader(BuildContext context, dynamic t) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            classEntity.headerColor.withValues(alpha: 0.8),
            classEntity.headerColor.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.classes.editForm.editing,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      classEntity.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          ...[
            const SizedBox(height: 12),
            Text(
              t.classes.editForm.teacher(teacherName: classEntity.teacherName),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataInfo(BuildContext context, dynamic t) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                t.classes.editForm.classInfo,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(context, t.classes.editForm.classId, classEntity.id),
          if (classEntity.createdAt != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              t.classes.editForm.created,
              _formatDateTime(classEntity.createdAt!),
            ),
          ],
          if (classEntity.updatedAt != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              t.classes.editForm.lastUpdated,
              _formatDateTime(classEntity.updatedAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
