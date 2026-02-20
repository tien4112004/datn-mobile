import 'dart:async';

import 'package:AIPrimary/features/assignments/domain/entity/matrix_template_entity.dart';
import 'package:AIPrimary/features/assignments/domain/repository/matrix_template_repository.dart';
import 'package:AIPrimary/features/assignments/states/controller_provider.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

/// A bottom sheet for selecting matrix templates from personal or public library.
///
/// Features:
/// - Personal/Public tabs using Material 3 TabBar
/// - Search bar with 300ms debounce
/// - Filter chips showing assignment grade & subject
/// - Paginated list with infinite scroll
/// - Radio button selection with compatibility checking
/// - Incompatible templates shown but disabled
///
/// Usage:
/// ```dart
/// final template = await MatrixTemplateSelectorSheet.show(
///   context,
///   assignmentGrade: '5',
///   assignmentSubject: 'T',
/// );
/// ```
class MatrixTemplateSelectorSheet {
  MatrixTemplateSelectorSheet._();

  /// Shows the template selector as a modal bottom sheet.
  ///
  /// [assignmentGrade] — Current assignment's grade for filtering
  /// [assignmentSubject] — Current assignment's subject for filtering
  static Future<MatrixTemplateEntity?> show(
    BuildContext context, {
    String? assignmentGrade,
    String? assignmentSubject,
  }) {
    return showModalBottomSheet<MatrixTemplateEntity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => _MatrixTemplateSelectorContent(
          scrollController: scrollController,
          assignmentGrade: assignmentGrade,
          assignmentSubject: assignmentSubject,
        ),
      ),
    );
  }
}

/// Content widget for the matrix template selector bottom sheet.
class _MatrixTemplateSelectorContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final String? assignmentGrade;
  final String? assignmentSubject;

  const _MatrixTemplateSelectorContent({
    required this.scrollController,
    this.assignmentGrade,
    this.assignmentSubject,
  });

  @override
  ConsumerState<_MatrixTemplateSelectorContent> createState() =>
      _MatrixTemplateSelectorContentState();
}

class _MatrixTemplateSelectorContentState
    extends ConsumerState<_MatrixTemplateSelectorContent>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  Timer? _debounceTimer;
  MatrixTemplateEntity? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    widget.scrollController.addListener(_onScroll);

    // Set filters and refresh to apply them
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(matrixTemplateControllerProvider.notifier);
      controller.setFilters(
        grade: widget.assignmentGrade,
        subject: widget.assignmentSubject,
      );
      controller.refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController.position.pixels >=
        widget.scrollController.position.maxScrollExtent - 200) {
      ref.read(matrixTemplateControllerProvider.notifier).loadNextPage();
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;

    // Switch bank type based on tab index
    final bankType = _tabController.index == 0 ? 'personal' : 'public';
    ref.read(matrixTemplateControllerProvider.notifier).setBankType(bankType);

    // Clear selection when switching tabs
    setState(() {
      _selectedTemplate = null;
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref
          .read(matrixTemplateControllerProvider.notifier)
          .setSearch(query.isEmpty ? null : query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final tt = t.assignments.detail.matrix.template;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final templatesAsync = ref.watch(matrixTemplateControllerProvider);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  LucideIcons.layoutGrid,
                  size: 24,
                  color: Colors.purple.shade600,
                ),
                const SizedBox(width: 12),
                Text(
                  tt.selectTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Tabs (Personal/Public)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: tt.personalTab),
                Tab(text: tt.publicTab),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: tt.searchHint,
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter chips
          if (widget.assignmentGrade != null ||
              widget.assignmentSubject != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const Icon(LucideIcons.listFilter, size: 16),
                  const SizedBox(width: 8),
                  if (widget.assignmentGrade != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tt.gradeFilter(grade: widget.assignmentGrade!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (widget.assignmentGrade != null &&
                      widget.assignmentSubject != null)
                    const SizedBox(width: 8),
                  if (widget.assignmentSubject != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tt.subjectFilter(subject: widget.assignmentSubject!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Template list
          Expanded(
            child: templatesAsync.when(
              data: (result) =>
                  _buildTemplateList(result, theme, colorScheme, tt),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error, theme, tt),
            ),
          ),

          // Import button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: FilledButton(
                onPressed: _selectedTemplate != null
                    ? () => Navigator.of(context).pop(_selectedTemplate)
                    : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(tt.importButton),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateList(
    MatrixTemplateListResult result,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic tt,
  ) {
    if (result.templates.isEmpty) {
      return _buildEmptyState(theme, tt);
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: result.templates.length + (result.pagination.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= result.templates.length) {
          // Loading indicator for next page
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final template = result.templates[index];
        final isCompatible = template.isCompatibleWith(
          assignmentGrade: widget.assignmentGrade,
          assignmentSubject: widget.assignmentSubject,
        );
        final isSelected = _selectedTemplate?.id == template.id;

        return _TemplateCard(
          template: template,
          isSelected: isSelected,
          isCompatible: isCompatible,
          tt: tt,
          onTap: isCompatible
              ? () => setState(() => _selectedTemplate = template)
              : null,
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, dynamic tt) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.inbox, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            tt.noTemplatesFound as String,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tt.tryDifferentSearch as String,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, ThemeData theme, dynamic tt) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.circleX, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            tt.loadError as String,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              ref.read(matrixTemplateControllerProvider.notifier).refresh();
            },
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: Text(tt.retry as String),
          ),
        ],
      ),
    );
  }
}

/// Individual template card with radio selection.
class _TemplateCard extends StatelessWidget {
  final MatrixTemplateEntity template;
  final bool isSelected;
  final bool isCompatible;
  final dynamic tt;
  final VoidCallback? onTap;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.isCompatible,
    required this.tt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: isCompatible ? 1.0 : 0.6,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Radio indicator
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // Template info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and badges row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              template.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (template.isPublic)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tt.publicBadge as String,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          if (!isCompatible)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.triangle,
                                    size: 10,
                                    color: Colors.orange.shade800,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    tt.incompatible as String,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Metadata row
                      Row(
                        children: [
                          Icon(
                            LucideIcons.grid3x3,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tt.topicsCount(count: template.totalTopics)
                                as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            LucideIcons.fileText,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tt.questionsCount(count: template.totalQuestions)
                                as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            LucideIcons.calendar,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            template.createdAt != null
                                ? DateFormat.yMd().format(template.createdAt!)
                                : '-',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Grade and subject badges
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tt.gradeBadge(grade: template.grade) as String,
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              template.subject,
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                        ],
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
}
