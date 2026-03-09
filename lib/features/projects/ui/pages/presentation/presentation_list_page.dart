import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/projects/data/repository/repository_provider.dart';
import 'package:AIPrimary/features/projects/domain/entity/presentation_minimal.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/features/projects/enum/sort_option.dart';
import 'package:AIPrimary/features/projects/states/presentation_provider.dart';
import 'package:AIPrimary/features/projects/states/presentation_paging_controller_pod.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/project_loading_skeleton.dart';
import 'package:AIPrimary/features/projects/ui/widgets/presentation/presentation_tile.dart';
import 'package:AIPrimary/features/projects/ui/widgets/presentation/presentation_grid_card.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/pods/view_preference_pod.dart';
import 'package:AIPrimary/shared/utils/snackbar_utils.dart';
import 'package:AIPrimary/shared/widgets/chapter_filter_chip.dart';
import 'package:AIPrimary/shared/widgets/generic_filters_bar.dart';
import 'package:AIPrimary/shared/widgets/enhanced_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';

@RoutePage()
class PresentationListPage extends ConsumerStatefulWidget {
  const PresentationListPage({super.key});

  @override
  ConsumerState<PresentationListPage> createState() =>
      _PresentationListPageState();
}

class _PresentationListPageState extends ConsumerState<PresentationListPage> {
  SortOption? _sortOption;
  GradeLevel? _gradeFilter;
  Subject? _subjectFilter;
  String? _chapterFilter;
  late TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _sortOption = SortOption.dateCreatedDesc;
    _searchController = TextEditingController();
    // Initialize filter with default sort
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(presentationFilterProvider.notifier).state =
          const PresentationFilterState();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(presentationFilterProvider.notifier).state = ref
          .read(presentationFilterProvider)
          .copyWith(searchQuery: query);
    });
  }

  void _updateFilter({
    GradeLevel? grade,
    bool clearGrade = false,
    Subject? subject,
    bool clearSubject = false,
    String? chapter,
    bool clearChapter = false,
    SortOption? sortOption,
    bool clearSort = false,
  }) {
    setState(() {
      if (clearGrade) {
        _gradeFilter = null;
        _subjectFilter = null;
        _chapterFilter = null;
      } else if (grade != null) {
        _gradeFilter = grade;
        _chapterFilter = null; // reset chapter when grade changes
      }
      if (clearSubject) {
        _subjectFilter = null;
        _chapterFilter = null;
      } else if (subject != null) {
        _subjectFilter = subject;
        _chapterFilter = null; // reset chapter when subject changes
      }
      if (clearChapter) {
        _chapterFilter = null;
      } else if (chapter != null) {
        _chapterFilter = chapter;
      }
      if (clearSort) {
        _sortOption = null;
      } else if (sortOption != null) {
        _sortOption = sortOption;
      }
    });

    ref
        .read(presentationFilterProvider.notifier)
        .state = PresentationFilterState(
      searchQuery: ref.read(presentationFilterProvider).searchQuery,
      sortOption: _sortOption,
      gradeFilter: _gradeFilter,
      subjectFilter: _subjectFilter,
      chapterFilter: _chapterFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final pagingController = ref.watch(presentationPagingControllerPod);
    final viewPreferenceAsync = ref.watch(
      viewPreferenceNotifierPod(ResourceType.presentation.name),
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 240,
            floating: false,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: colorScheme.surface,
            leading: Semantics(
              label: t.common.goBack,
              button: true,
              child: IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.router.maybePop();
                },
                tooltip: t.common.back,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.refreshCw),
                tooltip: t.common.refresh,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  pagingController.refresh();
                },
              ),
            ],
            title: Text(t.projects.presentations.title),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              background: Padding(
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Search field
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: t.projects.presentations.search_presentations,
                        prefixIcon: const Icon(LucideIcons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(LucideIcons.x, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                  ref
                                      .read(presentationFilterProvider.notifier)
                                      .state = ref
                                      .read(presentationFilterProvider)
                                      .copyWith(searchQuery: '');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filters and view toggle row
                    Row(
                      children: [
                        Expanded(
                          child: GenericFiltersBar(
                            useWrap: true,
                            filters: [
                              FilterConfig<SortOption>(
                                label: t.projects.common_list.filter_sort,
                                icon: LucideIcons.arrowUpDown,
                                selectedValue: _sortOption,
                                options: SortOption.values,
                                displayNameBuilder: (option) =>
                                    (option).displayName(t),
                                iconBuilder: (option) => (option).icon,
                                onChanged: (value) {
                                  _updateFilter(
                                    sortOption: value,
                                    clearSort: value == null,
                                  );
                                },
                              ),
                              FilterConfig<GradeLevel>(
                                label: t.projects.common_list.filter_grade,
                                icon: LucideIcons.graduationCap,
                                selectedValue: _gradeFilter,
                                options: GradeLevel.values,
                                displayNameBuilder: (g) =>
                                    g.getLocalizedName(t),
                                onChanged: (value) {
                                  if (value == null) {
                                    _updateFilter(clearGrade: true);
                                  } else {
                                    _updateFilter(grade: value);
                                  }
                                },
                              ),
                              FilterConfig<Subject>(
                                label: t.projects.common_list.filter_subject,
                                icon: LucideIcons.bookOpen,
                                selectedValue: _subjectFilter,
                                options: Subject.values,
                                displayNameBuilder: (s) =>
                                    s.getLocalizedName(t),
                                onChanged: (value) {
                                  if (value == null) {
                                    _updateFilter(clearSubject: true);
                                  } else {
                                    _updateFilter(subject: value);
                                  }
                                },
                              ),
                            ],
                            trailing: [
                              ChapterFilterChip(
                                grade: _gradeFilter,
                                subject: _subjectFilter,
                                selectedChapter: _chapterFilter,
                                onChanged: (chapter) {
                                  if (chapter == null) {
                                    _updateFilter(clearChapter: true);
                                  } else {
                                    _updateFilter(chapter: chapter);
                                  }
                                },
                              ),
                            ],
                            onClearFilters: () {
                              _searchController.clear();
                              setState(() {
                                _sortOption = null;
                                _gradeFilter = null;
                                _subjectFilter = null;
                                _chapterFilter = null;
                              });
                              ref
                                      .read(presentationFilterProvider.notifier)
                                      .state =
                                  const PresentationFilterState();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            viewPreferenceAsync
                                ? LucideIcons.list
                                : LucideIcons.layoutGrid,
                            size: 24,
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            ref
                                .read(
                                  viewPreferenceNotifierPod(
                                    ResourceType.presentation.name,
                                  ).notifier,
                                )
                                .toggle();
                          },
                          tooltip: viewPreferenceAsync
                              ? t.projects.common_list.view_list
                              : t.projects.common_list.view_grid,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: () async {
            pagingController.refresh();
          },
          child: PagingListener(
            controller: pagingController,
            builder: (context, state, fetchNextPage) {
              if (viewPreferenceAsync) {
                return _buildPagedListView(state, fetchNextPage);
              } else {
                return _buildPagedGridView(state, fetchNextPage);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPagedGridView(
    PagingState<int, PresentationMinimal> state,
    VoidCallback fetchNextPage,
  ) {
    final t = ref.watch(translationsPod);

    return PagedGridView<int, PresentationMinimal>(
      state: state,
      fetchNextPage: fetchNextPage,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      builderDelegate: PagedChildBuilderDelegate<PresentationMinimal>(
        itemBuilder: (context, item, index) => PresentationGridCard(
          presentation: item,
          onTap: () {
            HapticFeedback.lightImpact();
            context.router.push(
              PresentationDetailRoute(presentationId: item.id),
            );
          },
          onMoreOptions: () {
            _showMoreOptions(context, item);
          },
        ),
        firstPageProgressIndicatorBuilder: (context) =>
            const ProjectGridSkeletonLoader(),
        newPageProgressIndicatorBuilder: (context) => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        noItemsFoundIndicatorBuilder: (context) => EnhancedEmptyState(
          icon: LucideIcons.presentation,
          title: t.projects.no_presentations,
          message: t.projects.common_list.no_items_description(
            type: t.projects.presentations.title,
          ),
        ),
        firstPageErrorIndicatorBuilder: (context) => _ErrorIndicator(
          error: state.error.toString(),
          onRetry: () => ref.read(presentationPagingControllerPod).refresh(),
        ),
        newPageErrorIndicatorBuilder: (context) =>
            _NewPageErrorIndicator(onRetry: fetchNextPage),
        noMoreItemsIndicatorBuilder: (context) => Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              t.projects.presentations.noMore,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPagedListView(
    PagingState<int, PresentationMinimal> state,
    VoidCallback fetchNextPage,
  ) {
    final t = ref.watch(translationsPod);

    return PagedListView<int, PresentationMinimal>.separated(
      state: state,
      fetchNextPage: fetchNextPage,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      separatorBuilder: (context, index) =>
          const SizedBox(child: Divider(indent: 154, height: 1)),
      builderDelegate: PagedChildBuilderDelegate<PresentationMinimal>(
        itemBuilder: (context, item, index) => PresentationTile(
          presentation: item,
          onTap: () {
            HapticFeedback.lightImpact();
            context.router.push(
              PresentationDetailRoute(presentationId: item.id),
            );
          },
          onMoreOptions: () {
            _showMoreOptions(context, item);
          },
        ),
        firstPageProgressIndicatorBuilder: (context) =>
            const ProjectListSkeletonLoader(),
        newPageProgressIndicatorBuilder: (context) => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        noItemsFoundIndicatorBuilder: (context) => EnhancedEmptyState(
          icon: LucideIcons.presentation,
          title: t.projects.no_presentations,
          message: t.projects.common_list.no_items_description(
            type: t.projects.presentations.title,
          ),
        ),
        firstPageErrorIndicatorBuilder: (context) => _ErrorIndicator(
          error: state.error.toString(),
          onRetry: () => ref.read(presentationPagingControllerPod).refresh(),
        ),
        newPageErrorIndicatorBuilder: (context) =>
            _NewPageErrorIndicator(onRetry: fetchNextPage),
        noMoreItemsIndicatorBuilder: (context) => Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              t.projects.presentations.noMore,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreOptions(
    BuildContext context,
    PresentationMinimal presentation,
  ) {
    final t = ref.read(translationsPod);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(LucideIcons.trash2, color: colorScheme.error),
              title: Text(
                t.common.delete,
                style: TextStyle(color: colorScheme.error),
              ),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
                _confirmDelete(context, presentation, t);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    PresentationMinimal presentation,
    dynamic t,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.projects.presentations.deleteDialog.title),
        content: Text(
          t.projects.presentations.deleteDialog.message(
            title: presentation.title,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deletePresentation(presentation);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(t.common.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePresentation(PresentationMinimal presentation) async {
    final t = ref.read(translationsPod);
    try {
      await ref
          .read(presentationRepositoryProvider)
          .deletePresentation(presentation.id);
      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          t.projects.presentations.deleteDialog.success,
        );
        ref.read(presentationPagingControllerPod).refresh();
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          t.projects.presentations.deleteDialog.error,
        );
      }
    }
  }
}

class _ErrorIndicator extends ConsumerWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorIndicator({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.circleAlert, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              t.projects.presentations.failedToLoad,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw),
              label: Text(t.common.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewPageErrorIndicator extends ConsumerWidget {
  final VoidCallback onRetry;

  const _NewPageErrorIndicator({required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(LucideIcons.refreshCw, size: 16),
          label: Text(t.common.tapToRetry),
        ),
      ),
    );
  }
}
