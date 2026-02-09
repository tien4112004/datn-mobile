import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/features/projects/enum/sort_option.dart';
import 'package:AIPrimary/features/projects/states/mindmap_provider.dart';
import 'package:AIPrimary/features/projects/states/mindmap_paging_controller_pod.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/project_loading_skeleton.dart';
import 'package:AIPrimary/features/projects/ui/widgets/mindmap/mindmap_tile.dart';
import 'package:AIPrimary/features/projects/ui/widgets/mindmap/mindmap_grid_card.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/pods/view_preference_pod.dart';
import 'package:AIPrimary/shared/widgets/generic_filters_bar.dart';
import 'package:AIPrimary/shared/widgets/enhanced_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';

@RoutePage()
class MindmapListPage extends ConsumerStatefulWidget {
  const MindmapListPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MindmapListPageState();
}

class _MindmapListPageState extends ConsumerState<MindmapListPage> {
  SortOption? _sortOption;
  late TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _sortOption = SortOption.dateCreatedDesc;
    _searchController = TextEditingController();
    // Initialize filter with default sort
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mindmapFilterProvider.notifier).state = MindmapFilterState(
        sortOption: _sortOption,
      );
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
      // Update filter state which will trigger the paging controller to refresh
      final currentFilter = ref.read(mindmapFilterProvider);
      ref.read(mindmapFilterProvider.notifier).state = MindmapFilterState(
        searchQuery: query,
        sortOption: currentFilter.sortOption,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final pagingController = ref.watch(mindmapPagingControllerPod);
    final viewPreferenceAsync = ref.watch(
      viewPreferenceNotifierPod(ResourceType.mindmap.name),
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            floating: false,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: colorScheme.surface,
            leading: Semantics(
              label: 'Go back',
              button: true,
              hint: 'Double tap to return to previous page',
              child: IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.router.maybePop();
                },
                tooltip: 'Back',
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.refreshCw),
                tooltip: 'Refresh',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  pagingController.refresh();
                },
              ),
            ],
            title: Text(t.projects.mindmaps.title),
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
                        hintText: t.projects.mindmaps.search_mindmaps,
                        prefixIcon: const Icon(LucideIcons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(LucideIcons.x, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                  // Update filter and the paging controller will auto-refresh
                                  final currentFilter = ref.read(
                                    mindmapFilterProvider,
                                  );
                                  ref
                                      .read(mindmapFilterProvider.notifier)
                                      .state = MindmapFilterState(
                                    searchQuery: '',
                                    sortOption: currentFilter.sortOption,
                                  );
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
                                  setState(() {
                                    _sortOption = value;
                                  });
                                  // Update filter state with sort option
                                  final currentFilter = ref.read(
                                    mindmapFilterProvider,
                                  );
                                  ref
                                      .read(mindmapFilterProvider.notifier)
                                      .state = MindmapFilterState(
                                    searchQuery: currentFilter.searchQuery,
                                    sortOption: value,
                                  );
                                },
                              ),
                            ],
                            onClearFilters: () {
                              setState(() {
                                _sortOption = null;
                              });
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
                                    ResourceType.mindmap.name,
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
    PagingState<int, MindmapMinimal> state,
    VoidCallback fetchNextPage,
  ) {
    final t = ref.watch(translationsPod);

    return PagedGridView<int, MindmapMinimal>(
      state: state,
      fetchNextPage: fetchNextPage,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.95,
      ),
      builderDelegate: PagedChildBuilderDelegate<MindmapMinimal>(
        itemBuilder: (context, item, index) => MindmapGridCard(
          mindmap: item,
          onTap: () {
            HapticFeedback.lightImpact();
            context.router.push(MindmapDetailRoute(mindmapId: item.id));
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
          icon: LucideIcons.brain,
          title: t.projects.no_mindmaps,
          message: t.projects.common_list.no_items_description(
            type: t.projects.mindmaps.title,
          ),
        ),
        firstPageErrorIndicatorBuilder: (context) => _ErrorIndicator(
          error: state.error.toString(),
          onRetry: () => ref.read(mindmapPagingControllerPod).refresh(),
        ),
        newPageErrorIndicatorBuilder: (context) =>
            _NewPageErrorIndicator(onRetry: fetchNextPage),
        noMoreItemsIndicatorBuilder: (context) => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No more mindmaps',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPagedListView(
    PagingState<int, MindmapMinimal> state,
    VoidCallback fetchNextPage,
  ) {
    final t = ref.watch(translationsPod);

    return PagedListView<int, MindmapMinimal>.separated(
      state: state,
      fetchNextPage: fetchNextPage,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      separatorBuilder: (context, index) =>
          const SizedBox(child: Divider(indent: 154, height: 1)),
      builderDelegate: PagedChildBuilderDelegate<MindmapMinimal>(
        itemBuilder: (context, item, index) => MindmapTile(
          mindmap: item,
          onTap: () {
            HapticFeedback.lightImpact();
            context.router.push(MindmapDetailRoute(mindmapId: item.id));
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
          icon: LucideIcons.brain,
          title: t.projects.no_mindmaps,
          message: t.projects.common_list.no_items_description(
            type: t.projects.mindmaps.title,
          ),
        ),
        firstPageErrorIndicatorBuilder: (context) => _ErrorIndicator(
          error: state.error.toString(),
          onRetry: () => ref.read(mindmapPagingControllerPod).refresh(),
        ),
        newPageErrorIndicatorBuilder: (context) =>
            _NewPageErrorIndicator(onRetry: fetchNextPage),
        noMoreItemsIndicatorBuilder: (context) => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No more mindmaps',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, MindmapMinimal mindmap) {
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
                // TODO: Implement delete
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorIndicator extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorIndicator({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.circleAlert, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load mindmaps',
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
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewPageErrorIndicator extends StatelessWidget {
  final VoidCallback onRetry;

  const _NewPageErrorIndicator({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(LucideIcons.refreshCw, size: 16),
          label: const Text('Tap to retry'),
        ),
      ),
    );
  }
}
