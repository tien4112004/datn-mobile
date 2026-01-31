import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/projects/domain/entity/image_project_minimal.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/features/projects/enum/sort_option.dart';
import 'package:AIPrimary/features/projects/states/image_provider.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/project_loading_skeleton.dart';
import 'package:AIPrimary/features/projects/ui/widgets/image/image_grid_card.dart';
import 'package:AIPrimary/features/projects/ui/widgets/image/image_tile.dart';
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
class ImageListPage extends ConsumerStatefulWidget {
  const ImageListPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImageListPageState();
}

class _ImageListPageState extends ConsumerState<ImageListPage> {
  SortOption? _sortOption;
  late TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _sortOption = SortOption.nameAsc;
    _searchController = TextEditingController();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(imageProvider.notifier).loadImagesWithFilter();
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
      // Update filter and reload
      ref.read(imageFilterProvider.notifier).state = ImageFilterState(
        searchQuery: query,
      );
      ref.read(imageProvider.notifier).loadImagesWithFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final imageState = ref.watch(imageProvider);
    final viewPreferenceAsync = ref.watch(
      viewPreferenceNotifierPod(ResourceType.image.name),
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
                  ref.read(imageProvider.notifier).loadImagesWithFilter();
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
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Search field
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: t.projects.images.search_images,
                        prefixIcon: const Icon(LucideIcons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(LucideIcons.x, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  // Update filter and reload
                                  ref.read(imageFilterProvider.notifier).state =
                                      const ImageFilterState(searchQuery: '');
                                  ref
                                      .read(imageProvider.notifier)
                                      .loadImagesWithFilter();
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
                                    ResourceType.image.name,
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
        body: UnifiedResourceList<ImageProjectMinimal>(
          asyncItems: imageState.mapData((state) => state.images),
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
          skeletonGridBuilder: () => const ProjectGridSkeletonLoader(),
          skeletonListBuilder: () => const ProjectListSkeletonLoader(),
          emptyIcon: LucideIcons.image,
          emptyTitle: t.projects.no_images,
          emptyMessage: 'Create your first image to get started',
          onRefresh: () {
            ref.read(imageProvider.notifier).loadImagesWithFilter();
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
