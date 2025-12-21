import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/features/projects/providers/filter_provider.dart';
import 'package:datn_mobile/features/projects/ui/widgets/resource/resource_search_and_filter_bar.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _sortOption = '';
  }

  @override
  Widget build(BuildContext context) {
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
        title: t.projects.images.title,
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
            const Expanded(
              child: Center(child: Text('This is the image list view.')),
            ),
          ],
        ),
      ),
    );
  }
}
