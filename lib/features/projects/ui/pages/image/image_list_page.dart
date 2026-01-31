import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/features/projects/domain/entity/image_project_minimal.dart';
import 'package:AIPrimary/features/projects/enum/sort_option.dart';
import 'package:AIPrimary/features/projects/states/image_provider.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/widgets/generic_filters_bar.dart';
import 'package:AIPrimary/features/projects/states/image_paging_controller_pod.dart';
import 'package:AIPrimary/features/projects/ui/widgets/image/image_gallery_view.dart';
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
    _sortOption = SortOption.dateCreatedDesc;
    _searchController = TextEditingController();
    // Initialize filter with default sort
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(imageFilterProvider.notifier).state = ImageFilterState(
        sortOption: _sortOption?.toApiValue(),
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
      final currentFilter = ref.read(imageFilterProvider);
      ref.read(imageFilterProvider.notifier).state = ImageFilterState(
        searchQuery: query,
        sortOption: currentFilter.sortOption,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final pagingController = ref.watch(imagePagingControllerPod);
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
                                  // Update filter and the paging controller will auto-refresh
                                  final currentFilter = ref.read(
                                    imageFilterProvider,
                                  );
                                  ref
                                      .read(imageFilterProvider.notifier)
                                      .state = ImageFilterState(
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
                    // Filters row
                    GenericFiltersBar(
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
                            // Update filter state with sort option
                            final currentFilter = ref.read(imageFilterProvider);
                            ref
                                .read(imageFilterProvider.notifier)
                                .state = ImageFilterState(
                              searchQuery: currentFilter.searchQuery,
                              sortOption: value?.toApiValue(),
                            );
                          },
                          allLabel: '',
                          allIcon: LucideIcons.list,
                        ),
                      ],
                      onClearFilters: () {
                        // No clear action needed since sort is required
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: RefreshIndicator(
          onRefresh: () async {
            await ref.read(imageProvider.notifier).loadImagesWithFilter();
          },
          child: ImageGalleryView(
            pagingController: pagingController,
            onImageTap: (image) {
              HapticFeedback.lightImpact();
              context.router.push(ImageDetailRoute(imageId: image.id));
            },
            onMoreOptions: (image) {
              _showMoreOptions(context, image);
            },
          ),
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
