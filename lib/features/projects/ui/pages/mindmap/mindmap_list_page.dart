import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';
import 'package:datn_mobile/features/projects/providers/filter_provider.dart';
import 'package:datn_mobile/features/projects/providers/paging_controller_pod.dart';
import 'package:datn_mobile/features/projects/states/controller_provider.dart';
import 'package:datn_mobile/features/projects/ui/widgets/mindmap/mindmap_tile.dart';
import 'package:datn_mobile/features/projects/ui/widgets/resource/resource_search_and_filter_bar.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:datn_mobile/shared/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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

  @override
  void initState() {
    super.initState();
    _sortOption = '';
  }

  @override
  Widget build(BuildContext context) {
    final pagedMindmaps = ref.watch(mindmapsPagingControllerPod);
    final mindmapController = ref.watch(mindmapsControllerProvider);
    final t = ref.watch(translationsPod);

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
      appBar: CustomAppBar(
        title: t.projects.mindmaps.title,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResourceSearchAndFilterBar(
              hintText: t.projects.mindmaps.search_mindmaps,
              onSearchTap: () {
                context.router.push(const MindmapSearchRoute());
              },
              subjects: ['Math', 'Science', 'English', 'History', 'PE'],
              grades: ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5'],
              selectedSort: _sortOption,
              sortOptions: _sortOptions,
              onSubjectChanged: (subject) {
                ref.read(filterProvider.notifier).setSubject(subject);
              },
              onGradeChanged: (grade) {
                ref.read(filterProvider.notifier).setGrade(grade);
              },
              onSortChanged: (sort) {
                setState(() {
                  _sortOption = sort;
                });
              },
              onClearFilters: () {
                ref.read(filterProvider.notifier).clearFilters();
              },
            ),
            const SizedBox(height: 16),
            mindmapController.easyWhen(
              data: (listState) => Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(mindmapsControllerProvider.notifier)
                        .refresh();
                  },
                  child: listState.value.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                ResourceType.mindmap.icon,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                t.projects.no_presentations,
                                style: TextStyle(
                                  fontSize: Themes.fontSize.s18,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : PagingListener(
                          controller: pagedMindmaps,
                          builder: (context, state, fetchNextPage) =>
                              PagedListView.separated(
                                state: state,
                                fetchNextPage: fetchNextPage,
                                builderDelegate: PagedChildBuilderDelegate(
                                  noMoreItemsIndicatorBuilder: (context) =>
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Center(
                                          child: Text(
                                            'No more presentations',
                                            style: TextStyle(
                                              fontSize: Themes.fontSize.s14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      ),
                                  itemBuilder: (context, item, index) {
                                    var mindmap = item as MindmapMinimal;
                                    return MindmapTile(
                                      mindmap: mindmap,
                                      onTap: () {
                                        context.router.push(
                                          MindmapDetailRoute(
                                            mindmapId: mindmap.id,
                                          ),
                                        );
                                      },
                                      onMoreOptions: () {
                                        // TODO: Show options menu
                                      },
                                    );
                                  },
                                ),
                                separatorBuilder: (context, index) => SizedBox(
                                  height: Themes.padding.p8,
                                  child: const Divider(
                                    height: 1,
                                    color: Color.fromRGBO(189, 189, 189, 1),
                                  ),
                                ),
                              ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
