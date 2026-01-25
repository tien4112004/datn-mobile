import 'package:datn_mobile/features/classes/domain/entity/linked_resource_entity.dart';
import 'package:datn_mobile/features/classes/domain/entity/permission_level.dart';
import 'package:datn_mobile/features/assignments/domain/entity/assignment_entity.dart';
import 'package:datn_mobile/features/assignments/states/controller_provider.dart';
import 'package:datn_mobile/shared/models/cms_enums.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:datn_mobile/shared/widget/generic_filters_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AssignmentSelectorSheet extends ConsumerStatefulWidget {
  final List<LinkedResourceEntity> alreadySelected;

  const AssignmentSelectorSheet({super.key, this.alreadySelected = const []});

  @override
  ConsumerState<AssignmentSelectorSheet> createState() =>
      _AssignmentSelectorSheetState();
}

class _AssignmentSelectorSheetState
    extends ConsumerState<AssignmentSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  Subject? _filterSubject;
  GradeLevel? _filterGrade;

  @override
  void initState() {
    super.initState();
    // Pre-populate with already selected assignments
    for (final resource in widget.alreadySelected) {
      if (resource.type == 'assignment') {
        _selectedIds.add(resource.id);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
    HapticFeedback.selectionClick();
  }

  void _clearFilters() {
    setState(() {
      _filterSubject = null;
      _filterGrade = null;
      _searchController.clear();
    });
  }

  List<AssignmentEntity> _filterAssignments(
    List<AssignmentEntity> assignments,
  ) {
    var filtered = assignments;

    // Apply subject filter
    if (_filterSubject != null) {
      filtered = filtered.where((a) => a.subject == _filterSubject).toList();
    }

    // Apply grade filter
    if (_filterGrade != null) {
      filtered = filtered.where((a) => a.gradeLevel == _filterGrade).toList();
    }

    // Apply search filter
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (a) =>
                a.title.toLowerCase().contains(searchQuery) ||
                (a.description?.toLowerCase().contains(searchQuery) ?? false),
          )
          .toList();
    }

    return filtered;
  }

  void _handleDone(List<AssignmentEntity> allAssignments) {
    final selectedResources = allAssignments
        .where((a) => _selectedIds.contains(a.assignmentId))
        .map(
          (a) => LinkedResourceEntity(
            id: a.assignmentId,
            type: 'assignment',
            permissionLevel: PermissionLevel.view,
          ),
        )
        .toList();

    Navigator.of(context).pop(selectedResources);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final assignmentsAsync = ref.watch(assignmentsControllerProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Assignments',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_selectedIds.length} selected',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Done button
                FilledButton(
                  onPressed: () {
                    assignmentsAsync.whenData((result) {
                      _handleDone(result.assignments);
                    });
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search assignments...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        onPressed: () {
                          setState(() => _searchController.clear());
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          const SizedBox(height: 12),

          // Filter bar using generic filters
          GenericFiltersBar(
            filters: [
              FilterConfig<Subject>(
                label: 'Subject',
                icon: LucideIcons.book,
                selectedValue: _filterSubject,
                options: Subject.values,
                displayNameBuilder: (subject) => subject.displayName,
                iconBuilder: (subject) => _getSubjectIcon(subject),
                onChanged: (subject) =>
                    setState(() => _filterSubject = subject),
                allLabel: 'All Subjects',
                allIcon: LucideIcons.book,
              ),
              FilterConfig<GradeLevel>(
                label: 'Grade',
                icon: LucideIcons.graduationCap,
                selectedValue: _filterGrade,
                options: GradeLevel.values,
                displayNameBuilder: (grade) => grade.displayName,
                onChanged: (grade) => setState(() => _filterGrade = grade),
                allLabel: 'All Grades',
                allIcon: LucideIcons.graduationCap,
              ),
            ],
            onClearFilters: _clearFilters,
          ),

          // Assignment list
          Expanded(
            child: assignmentsAsync.easyWhen(
              data: (result) {
                final filtered = _filterAssignments(result.assignments);

                if (filtered.isEmpty) {
                  return _buildEmptyState(theme, colorScheme);
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final assignment = filtered[index];
                    final isSelected = _selectedIds.contains(
                      assignment.assignmentId,
                    );

                    return _AssignmentSelectionTile(
                      assignment: assignment,
                      isSelected: isSelected,
                      onTap: () => _toggleSelection(assignment.assignmentId),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.fileSearch,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No assignments found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSubjectIcon(Subject subject) {
    switch (subject) {
      case Subject.english:
        return LucideIcons.messageSquare;
      case Subject.mathematics:
        return LucideIcons.calculator;
      case Subject.literature:
        return LucideIcons.bookOpen;
    }
  }
}

/// Individual assignment tile with selection state
class _AssignmentSelectionTile extends StatelessWidget {
  final AssignmentEntity assignment;
  final bool isSelected;
  final VoidCallback onTap;

  const _AssignmentSelectionTile({
    required this.assignment,
    required this.isSelected,
    required this.onTap,
  });

  Color _getSubjectColor(Subject subject) {
    switch (subject) {
      case Subject.english:
        return const Color(0xFF2563EB);
      case Subject.mathematics:
        return const Color(0xFFDC2626);
      case Subject.literature:
        return const Color(0xFF16A34A);
    }
  }

  IconData _getSubjectIcon(Subject subject) {
    switch (subject) {
      case Subject.english:
        return LucideIcons.messageSquare;
      case Subject.mathematics:
        return LucideIcons.calculator;
      case Subject.literature:
        return LucideIcons.bookOpen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subjectColor = _getSubjectColor(assignment.subject);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: isSelected,
                onChanged: (_) => onTap(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(width: 12),

              // Subject icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: subjectColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getSubjectIcon(assignment.subject),
                  size: 20,
                  color: subjectColor,
                ),
              ),

              const SizedBox(width: 12),

              // Assignment info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildBadge(
                          context,
                          icon: _getSubjectIcon(assignment.subject),
                          label: assignment.subject.displayName,
                          color: subjectColor,
                        ),
                        _buildBadge(
                          context,
                          icon: LucideIcons.graduationCap,
                          label: assignment.gradeLevel.displayName,
                          color: colorScheme.secondary,
                        ),
                        _buildBadge(
                          context,
                          icon: LucideIcons.listOrdered,
                          label: '${assignment.totalQuestions} Q',
                          color: colorScheme.tertiary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status indicator
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    assignment.status,
                    colorScheme,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  AssignmentStatus.getStatusIcon(assignment.status),
                  size: 16,
                  color: _getStatusColor(assignment.status, colorScheme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AssignmentStatus status, ColorScheme colorScheme) {
    switch (status) {
      case AssignmentStatus.completed:
        return const Color(0xFF16A34A);
      case AssignmentStatus.draft:
        return colorScheme.tertiary;
      case AssignmentStatus.generating:
        return const Color(0xFF2563EB);
      case AssignmentStatus.error:
        return colorScheme.error;
      case AssignmentStatus.archived:
        return colorScheme.outline;
    }
  }
}
