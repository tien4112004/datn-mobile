import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:datn_mobile/features/projects/enum/sort_option.dart';
import 'package:datn_mobile/features/projects/providers/paging_controller_pod.dart';
import 'package:datn_mobile/features/projects/ui/widgets/mindmap/mindmap_tile.dart';
import 'package:datn_mobile/features/projects/ui/widgets/mindmap/mindmap_grid_card.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/pods/view_preference_pod.dart';
import 'package:datn_mobile/shared/widget/generic_filters_bar.dart';
import 'package:datn_mobile/shared/widget/unified_resource_list.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final pagingController = ref.watch(
      mindmapPagingControllerPod((_searchQuery, _sortOption)),
    );
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
                                label: 'Sort',
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
                                },
                                allLabel: 'Default Sort',
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
                              ? 'List view'
                              : 'Grid view',
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
          pagingController: pagingController,
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
          emptyIcon: LucideIcons.brain,
          emptyTitle: 'No mindmaps available',
          emptyMessage: 'Create your first mindmap to get started',
          noMoreItemsText: 'No more mindmaps',
          onRefresh: () {
            pagingController.refresh();
          },
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, MindmapMinimal mindmap) {
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
              title: Text('Delete', style: TextStyle(color: colorScheme.error)),
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
