import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/states/controller_provider.dart';
import 'package:datn_mobile/features/projects/providers/filter_provider.dart';
import 'package:datn_mobile/features/projects/ui/widgets/presentation/presentation_tile.dart';
import 'package:datn_mobile/features/projects/ui/widgets/resource/filter_and_sort_bar.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:datn_mobile/shared/widget/app_app_bar.dart';
import 'package:datn_mobile/shared/widget/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ResourceListPage extends ConsumerStatefulWidget {
  final String resourceType;

  const ResourceListPage({
    super.key,
    @PathParam('resourceType') required this.resourceType,
  });

  @override
  ConsumerState<ResourceListPage> createState() => _ResourceListPageState();
}

class _ResourceListPageState extends ConsumerState<ResourceListPage> {
  late String _sortOption;
  late List<String> _sortOptions;

  @override
  void initState() {
    super.initState();
    // Initialize with default value - will be updated in build
    _sortOption = '';
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsPod);

    _sortOptions = [
      t.projects.sort_date_modified,
      t.projects.sort_date_created,
      t.projects.sort_name_asc,
      t.projects.sort_name_desc,
    ];

    if (_sortOption.isEmpty || !_sortOptions.contains(_sortOption)) {
      _sortOption = t.projects.sort_date_modified;
    }

    return Scaffold(
      appBar: AppAppBar(
        title: t.projects.title,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _buildContent(context, t),
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic t) {
    // Only show presentations list for "Presentations" resource type
    if (widget.resourceType != 'Presentations') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.construction,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              t.projects.coming_soon(type: widget.resourceType),
              style: TextStyle(
                fontSize: Themes.fontSize.s18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    final presentationControllerProvider = ref.watch(
      presentationsControllerProvider,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar - opens dedicated search page
        InkWell(
          child: CustomSearchBar(
            enabled: false,
            autoFocus: false,
            hintText: t.projects.presentations.search_presentations,
            onTap: () {},
          ),
          onTap: () {
            context.router.push(const PresentationSearchRoute());
          },
        ),
        const SizedBox(height: 16),
        // Filter and Sort bar
        FilterAndSortBar(
          // This filter and sort options are just placeholders
          // TODO: should be dynamic based on actual data
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
        // Presentations list
        presentationControllerProvider.easyWhen(
          data: (presentationListState) => Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(presentationsControllerProvider.notifier)
                    .refresh();
              },
              child: presentationListState.value.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.presentation,
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
                  : ListView.separated(
                      itemCount: presentationListState.value.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 0),
                      itemBuilder: (context, index) {
                        final presentation = presentationListState.value[index];
                        return PresentationTile(
                          presentation: presentation,
                          onTap: () {
                            context.router.push(
                              PresentationDetailRoute(
                                presentationId: presentation.id,
                              ),
                            );
                          },
                          onMoreOptions: () {
                            // TODO: Show options menu
                          },
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
