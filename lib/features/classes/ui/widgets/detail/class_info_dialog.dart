import 'package:AIPrimary/features/classes/domain/entity/class_entity.dart';
import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Comprehensive class information dialog following Material Design 3 guidelines.
/// Displays all class details in a clean, organized format with accessibility support.
class ClassInfoDialog {
  /// Shows the class information dialog.
  static void show(BuildContext context, ClassEntity classEntity) {
    showDialog(
      context: context,
      builder: (context) => _ClassInfoDialogContent(classEntity: classEntity),
    );
  }
}

class _ClassInfoDialogContent extends ConsumerWidget {
  final ClassEntity classEntity;

  const _ClassInfoDialogContent({required this.classEntity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 3,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            _buildHeader(context),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Basic Information Card
                    _buildInfoCard(
                      context: context,
                      title: 'Basic Information',
                      icon: LucideIcons.info,
                      children: [
                        _buildInfoRow(
                          context: context,
                          label: 'Class Name',
                          value: classEntity.name,
                        ),
                        if (classEntity.description != null &&
                            classEntity.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context: context,
                            label: 'Description',
                            value: classEntity.description!,
                            isMultiline: true,
                          ),
                        ],
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context: context,
                          label: 'Status',
                          value: classEntity.isActive ? 'Active' : 'Inactive',
                          valueColor: classEntity.isActive
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          trailing: Icon(
                            classEntity.isActive
                                ? LucideIcons.circleCheck
                                : LucideIcons.circleX,
                            size: 18,
                            color: classEntity.isActive
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Instructor Information Card
                    _buildInfoCard(
                      context: context,
                      title: 'Instructor',
                      icon: LucideIcons.user,
                      children: [
                        _buildInfoRow(
                          context: context,
                          label: 'Name',
                          value: classEntity.teacherName,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context: context,
                          label: 'Owner ID',
                          value: classEntity.teacherId,
                          isMonospace: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Join Code Card
                    if (classEntity.joinCode != null)
                      _buildInfoCard(
                        context: context,
                        title: 'Enrollment',
                        icon: LucideIcons.link,
                        children: [
                          _buildInfoRow(
                            context: context,
                            label: 'Join Code',
                            value: classEntity.joinCode!,
                            isMonospace: true,
                            onCopy: () => _copyToClipboard(
                              context,
                              classEntity.joinCode!,
                              'Join code copied to clipboard',
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // Timestamps Card
                    _buildInfoCard(
                      context: context,
                      title: 'Timestamps',
                      icon: LucideIcons.clock,
                      children: [
                        if (classEntity.createdAt != null) ...[
                          _buildInfoRow(
                            context: context,
                            label: 'Created',
                            value: DateFormatHelper.formatRelativeDate(
                              ref: ref,
                              classEntity.createdAt!,
                            ),
                          ),
                          if (classEntity.updatedAt != null)
                            const SizedBox(height: 12),
                        ],
                        if (classEntity.updatedAt != null)
                          _buildInfoRow(
                            context: context,
                            label: 'Last Updated',
                            value: DateFormatHelper.formatRelativeDate(
                              ref: ref,
                              classEntity.updatedAt!,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            classEntity.headerColor,
            classEntity.headerColor.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  label: 'Class information for ${classEntity.name}',
                  child: Text(
                    'Class Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  classEntity.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Semantics(
            label: 'Close dialog',
            button: true,
            hint: 'Double tap to close class information',
            child: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              icon: const Icon(LucideIcons.x),
              color: Colors.white,
              tooltip: 'Close',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
    bool isMultiline = false,
    bool isMonospace = false,
    Color? valueColor,
    Widget? trailing,
    VoidCallback? onCopy,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: valueColor ?? colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontFamily: isMonospace ? 'monospace' : null,
                  height: isMultiline ? 1.5 : null,
                ),
                maxLines: isMultiline ? null : 1,
                overflow: isMultiline ? null : TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing],
            if (onCopy != null) ...[
              const SizedBox(width: 8),
              Semantics(
                label: 'Copy $label',
                button: true,
                hint: 'Double tap to copy to clipboard',
                child: IconButton(
                  icon: Icon(
                    LucideIcons.copy,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  onPressed: onCopy,
                  tooltip: 'Copy to clipboard',
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text, String message) {
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: text));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                LucideIcons.circleCheck,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(message),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
