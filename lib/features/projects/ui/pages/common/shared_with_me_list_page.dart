import 'package:auto_route/auto_route.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/projects/domain/entity/shared_resource.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/features/projects/states/controller_provider.dart';
import 'package:AIPrimary/features/projects/ui/widgets/common/resource_grid_card.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:AIPrimary/shared/widgets/custom_app_bar.dart';
import 'package:AIPrimary/shared/widgets/custom_search_bar.dart';
import 'package:AIPrimary/shared/widgets/enhanced_empty_state.dart';
import 'package:AIPrimary/shared/widgets/generic_filters_bar.dart';
import 'package:AIPrimary/shared/widgets/skeleton_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class SharedWithMeListPage extends ConsumerStatefulWidget {
  const SharedWithMeListPage({super.key});

  @override
  ConsumerState<SharedWithMeListPage> createState() =>
      _SharedWithMeListPageState();
}

class _SharedWithMeListPageState extends ConsumerState<SharedWithMeListPage> {
  String _searchQuery = '';
  ResourceType? _selectedType;

  List<SharedResource> _applyFilters(List<SharedResource> resources) {
    return resources.where((resource) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          resource.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          resource.ownerName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType =
          _selectedType == null || resource.type == _selectedType!.label;
      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final sharedResourcesAsync = ref.watch(sharedResourcesControllerProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: t.projects.shared_with_me,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: t.common.refresh,
            onPressed: () =>
                ref.read(sharedResourcesControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              Themes.padding.p16,
              Themes.padding.p8,
              Themes.padding.p16,
              0,
            ),
            child: CustomSearchBar(
              hintText: t.projects.search_shared,
              enabled: true,
              autoFocus: false,
              onChanged: (query) => setState(() => _searchQuery = query),
              onClearTap: () => setState(() => _searchQuery = ''),
            ),
          ),
          GenericFiltersBar(
            filters: [
              FilterConfig<ResourceType>(
                label: t.projects.common_list.filter_all,
                icon: LucideIcons.layoutGrid,
                selectedValue: _selectedType,
                options: const [
                  ResourceType.mindmap,
                  ResourceType.presentation,
                ],
                displayNameBuilder: (type) => type.getLabel(t),
                iconBuilder: (type) => type.icon,
                onChanged: (value) => setState(() => _selectedType = value),
              ),
            ],
            onClearFilters: () => setState(() => _selectedType = null),
          ),
          Expanded(
            child: sharedResourcesAsync.easyWhen(
              data: (sharedResourceListState) {
                final filtered = _applyFilters(sharedResourceListState.value);
                if (filtered.isEmpty) {
                  return EnhancedEmptyState(
                    icon: LucideIcons.share2,
                    title: t.projects.no_shared_resources,
                    message: t.projects.common_list.no_results_message,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(sharedResourcesControllerProvider.notifier)
                        .refresh();
                  },
                  child: GridView.builder(
                    padding: EdgeInsets.all(Themes.padding.p16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final resource = filtered[index];
                      final resourceType = ResourceType.fromValue(
                        resource.type.toLowerCase(),
                      );
                      return ResourceGridCard(
                        title: resource.title,
                        description:
                            '${t.projects.shared_by(ownerName: resource.ownerName)} - ${resourceType.getLabel(t)}',
                        thumbnail: resource.thumbnailUrl,
                        resourceType: resourceType,
                        onTap: () {
                          switch (resourceType) {
                            case ResourceType.presentation:
                              context.router.push(
                                PresentationDetailRoute(
                                  presentationId: resource.id,
                                ),
                              );
                            case ResourceType.mindmap:
                              context.router.push(
                                MindmapDetailRoute(mindmapId: resource.id),
                              );
                            case ResourceType.image:
                              context.router.push(
                                ImageDetailRoute(imageId: resource.id),
                              );
                            case ResourceType.question:
                              context.router.push(
                                QuestionDetailRoute(questionId: resource.id),
                              );
                            case ResourceType.assignment:
                              context.router.push(
                                AssignmentDetailRoute(
                                  assignmentId: resource.id,
                                ),
                              );
                          }
                        },
                      );
                    },
                  ),
                );
              },
              loadingWidget: () => GridView.builder(
                padding: EdgeInsets.all(Themes.padding.p16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 6,
                itemBuilder: (context, index) =>
                    const SkeletonCard(badgeCount: 1, showSubtitle: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
