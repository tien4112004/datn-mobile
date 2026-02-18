import 'package:AIPrimary/features/assignments/domain/entity/assignment_entity.dart';
import 'package:AIPrimary/features/assignments/ui/widgets/assignment_form_dialog.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/utils/enum_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MetadataTab extends ConsumerWidget {
  final AssignmentEntity assignment;
  final bool isEditMode;
  const MetadataTab({
    super.key,
    required this.assignment,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Container(
      color: colorScheme.surfaceContainerLowest,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (assignment.createdAt != null) ...[
                          Text(
                            t.assignments.detail.metadata.createdOn(
                              date: DateFormatHelper.formatMediumDate(
                                assignment.createdAt!,
                                ref: ref,
                              ),
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isEditMode)
                    IconButton(
                      icon: const Icon(LucideIcons.pencil, size: 20),
                      onPressed: () => _showEditDialog(context),
                      tooltip: t.assignments.detail.metadata.editAssignment,
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                ],
              ),
            ),

            // Assignment Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    separatorBuilder: (context, index) {
                      return Divider(
                        indent: 0,
                        height: 1,
                        color: colorScheme.outlineVariant,
                      );
                    },
                    itemBuilder: (context, index) {
                      final metrics = [
                        (
                          icon: LucideIcons.bookOpen,
                          label: t.assignments.detail.metadata.subject,
                          value: assignment.subject.localizedName(t),
                        ),
                        (
                          icon: LucideIcons.graduationCap,
                          label: t.assignments.detail.metadata.gradeLevel,
                          value: assignment.gradeLevel.localizedName(t),
                        ),
                        (
                          icon: LucideIcons.listChecks,
                          label: t.assignments.detail.metadata.totalQuestions,
                          value: '${assignment.totalQuestions}',
                        ),
                      ];

                      final metric = metrics[index];
                      return _buildMetricRow(
                        context,
                        icon: metric.icon,
                        label: metric.label,
                        value: metric.value,
                        theme: theme,
                        colorScheme: colorScheme,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Description section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    t.assignments.detail.metadata.description,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Text(
                  (assignment.description == null ||
                          assignment.description!.isEmpty)
                      ? t.assignments.detail.metadata.noDescription
                      : assignment.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bottom padding
            SizedBox(height: isEditMode ? 174.0 : 88.0),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AssignmentFormDialog(assignment: assignment),
    );
  }
}
