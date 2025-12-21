import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/projects/domain/entity/image_project_minimal.dart';
import 'package:datn_mobile/features/projects/providers/filter_provider.dart';
import 'package:datn_mobile/features/projects/providers/paging_controller_pod.dart';
import 'package:datn_mobile/features/projects/ui/widgets/image/image_tile.dart';
import 'package:datn_mobile/features/projects/ui/widgets/resource/resource_search_and_filter_bar.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
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

  @override
  void initState() {
    super.initState();
    _sortOption = '';
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);
    final pagingController = ref.watch(imagePagingControllerPod);

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
        title: t.projects.images.title,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.router.push(const GenerateRoute());
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        highlightElevation: 0,
        child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 32),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResourceSearchAndFilterBar(
              hintText: t.projects.images.search_images,
              onSearchTap: () {
                context.router.push(const ImageSearchRoute());
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
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  pagingController.refresh();
                },
                child: PagingListener(
                  controller: pagingController,
                  builder: (context, state, fetchNextPage) =>
                      PagedListView.separated(
                        fetchNextPage: fetchNextPage,
                        state: state,
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 8,
                          child: Divider(
                            height: 1,
                            color: Color.fromRGBO(189, 189, 189, 1),
                          ),
                        ),
                        builderDelegate:
                            PagedChildBuilderDelegate<ImageProjectMinimal>(
                              itemBuilder: (context, item, index) => ImageTile(
                                image: item,
                                onTap: () {
                                  context.router.push(
                                    ImageDetailRoute(imageId: item.id),
                                  );
                                },
                                onMoreOptions: () {
                                  _showMoreOptions(context, item);
                                },
                              ),
                              noMoreItemsIndicatorBuilder: (context) => Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    t.projects.no_images,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                              noItemsFoundIndicatorBuilder: (context) => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.image,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      t.projects.no_images,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              firstPageErrorIndicatorBuilder: (context) =>
                                  const Center(
                                    child: Text(
                                      "t.projects.error_loading_images",
                                    ),
                                  ),
                              newPageErrorIndicatorBuilder: (context) =>
                                  const Center(
                                    child: Text(
                                      "t.projects.error_loading_images",
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

  void _showMoreOptions(BuildContext context, ImageProjectMinimal image) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Delete'),
              trailing: const Icon(LucideIcons.trash2),
              onTap: () {
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
