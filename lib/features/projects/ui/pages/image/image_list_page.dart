import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/projects/domain/entity/image_project_minimal.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:datn_mobile/features/projects/providers/paging_controller_pod.dart';
import 'package:datn_mobile/features/projects/ui/widgets/image/image_grid_card.dart';
import 'package:datn_mobile/features/projects/ui/widgets/image/image_tile.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/pods/view_preference_pod.dart';
import 'package:datn_mobile/shared/widget/resource_list_header.dart';
import 'package:datn_mobile/shared/widget/unified_resource_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ImageListPage extends ConsumerStatefulWidget {
  const ImageListPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImageListPageState();
}

class _ImageListPageState extends ConsumerState<ImageListPage> {
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
    final pagingController = ref.watch(imagePagingControllerPod(_searchQuery));
    final viewPreferenceAsync = ref.watch(
      viewPreferenceNotifierPod(ResourceType.image.name),
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
            title: Text(t.projects.images.title),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
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
                            ResourceType.image.name,
                          ).notifier,
                        )
                        .toggle();
                  },
                  searchHint: t.projects.images.search_images,
                  t: t,
                ),
              ),
            ),
          ),
        ],
        body: UnifiedResourceList<ImageProjectMinimal>(
          pagingController: pagingController,
          isGridView: viewPreferenceAsync,
          gridCardBuilder: (item) => ImageGridCard(
            image: item,
            onTap: () {
              HapticFeedback.lightImpact();
              context.router.push(ImageDetailRoute(imageId: item.id));
            },
            onMoreOptions: () {
              _showMoreOptions(context, item);
            },
          ),
          listTileBuilder: (item) => ImageTile(
            image: item,
            onTap: () {
              HapticFeedback.lightImpact();
              context.router.push(ImageDetailRoute(imageId: item.id));
            },
            onMoreOptions: () {
              _showMoreOptions(context, item);
            },
          ),
          emptyIcon: LucideIcons.image,
          emptyTitle: t.projects.no_images,
          emptyMessage: 'Create your first image to get started',
          noMoreItemsText: t.projects.no_images,
          onRefresh: () {
            pagingController.refresh();
          },
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, ImageProjectMinimal image) {
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
