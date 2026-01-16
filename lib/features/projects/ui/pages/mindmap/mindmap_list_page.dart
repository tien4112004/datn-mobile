import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:datn_mobile/features/projects/providers/paging_controller_pod.dart';
import 'package:datn_mobile/features/projects/ui/widgets/mindmap/mindmap_tile.dart';
import 'package:datn_mobile/features/projects/ui/widgets/mindmap/mindmap_grid_card.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/pods/view_preference_pod.dart';
import 'package:datn_mobile/shared/widget/resource_list_header.dart';
import 'package:datn_mobile/shared/widget/unified_resource_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class MindmapListPage extends ConsumerStatefulWidget {
  const MindmapListPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MindmapListPageState();
}

class _MindmapListPageState extends ConsumerState<MindmapListPage> {
  late String _sortOption;
  late List<String> _sortOptions;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _sortOption = '';
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final pagingController = ref.watch(
      mindmapPagingControllerPod(_searchQuery),
    );
    final viewPreferenceAsync = ref.watch(
      viewPreferenceNotifierPod(ResourceType.mindmap.name),
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    _sortOptions = [
      t.projects.common_list.sort_date_modified,
      t.projects.common_list.sort_date_created,
      t.projects.common_list.sort_name_asc,
      t.projects.common_list.sort_name_desc,
    ];

    if (_sortOption.isEmpty || !_sortOptions.contains(_sortOption)) {
      _sortOption = t.projects.common_list.sort_date_modified;
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 172,
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
              titlePadding: const EdgeInsets.only(left: 16, right: 16),
              background: Padding(
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                child: ResourceListHeader(
                  searchQuery: _searchQuery,
                  onSearchChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                  selectedSort: _sortOption,
                  sortOptions: _sortOptions,
                  onSortChanged: (sort) {
                    setState(() {
                      _sortOption = sort;
                    });
                  },
                  showViewToggle: true,
                  isGridView: viewPreferenceAsync,
                  onViewToggle: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(
                          viewPreferenceNotifierPod(
                            ResourceType.mindmap.name,
                          ).notifier,
                        )
                        .toggle();
                  },
                  searchHint: t.projects.mindmaps.search_mindmaps,
                  t: t,
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
