import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/features/projects/enum/sort_option.dart';
import 'package:AIPrimary/features/projects/states/mindmap_provider.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/project_loading_skeleton.dart';
import 'package:AIPrimary/features/projects/ui/widgets/mindmap/mindmap_tile.dart';
import 'package:AIPrimary/features/projects/ui/widgets/mindmap/mindmap_grid_card.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/pods/view_preference_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_transform.dart';
import 'package:AIPrimary/shared/widgets/generic_filters_bar.dart';
import 'package:AIPrimary/shared/widgets/unified_resource_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  String _searchQuery = '';
  late TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _sortOption = SortOption.nameAsc;
    _searchController = TextEditingController();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mindmapProvider.notifier).loadMindmapsWithFilter();
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
      setState(() {
        _searchQuery = query;
      });
      // Update filter and reload
      ref.read(mindmapFilterProvider.notifier).state = MindmapFilterState(
        searchQuery: query,
        sortOption: _sortOption,
      );
      ref.read(mindmapProvider.notifier).loadMindmapsWithFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final mindmapState = ref.watch(mindmapProvider);
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
                  ref.read(mindmapProvider.notifier).loadMindmapsWithFilter();
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
                                  setState(() {
                                    _searchQuery = '';
                                  });
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
                                  // Update filter and reload
                                  ref
                                      .read(mindmapFilterProvider.notifier)
                                      .state = MindmapFilterState(
                                    searchQuery: _searchQuery,
                                    sortOption: value,
                                  );
                                  ref
                                      .read(mindmapProvider.notifier)
                                      .loadMindmapsWithFilter();
                                },
                                allLabel: t.projects.common_list.sort_default,
                                allIcon: LucideIcons.list,
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
        body: UnifiedResourceList<MindmapMinimal>(
          asyncItems: mindmapState.mapData((state) => state.mindmaps),
          isGridView: viewPreferenceAsync,
          gridCardBuilder: (item) => MindmapGridCard(
            mindmap: item,
            onTap: () {
              HapticFeedback.lightImpact();
              // TODO: Navigate to mindmap detail when route is available
              // context.router.push(MindmapDetailRoute(mindmapId: item.id));
            },
            onMoreOptions: () {
              _showMoreOptions(context, item);
            },
          ),
          listTileBuilder: (item) => MindmapTile(
            mindmap: item,
            onTap: () {
              HapticFeedback.lightImpact();
              // TODO: Navigate to mindmap detail when route is available
              // context.router.push(MindmapDetailRoute(mindmapId: item.id));
            },
            onMoreOptions: () {
              _showMoreOptions(context, item);
            },
          ),
          skeletonGridBuilder: () => const ProjectGridSkeletonLoader(),
          skeletonListBuilder: () => const ProjectListSkeletonLoader(),
          emptyIcon: LucideIcons.brain,
          emptyTitle: t.projects.no_mindmaps,
          emptyMessage: t.projects.common_list.no_items_description(
            type: t.projects.mindmaps.title,
          ),
          onRefresh: () {
            ref.read(mindmapProvider.notifier).loadMindmapsWithFilter();
          },
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
