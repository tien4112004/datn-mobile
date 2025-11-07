import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/controllers/controller_provider.dart';
import 'package:datn_mobile/features/projects/providers/filter_provider.dart';
import 'package:datn_mobile/features/projects/ui/widgets/presentation/presentation_tile.dart';
import 'package:datn_mobile/features/projects/ui/widgets/resource/filter_and_sort_bar.dart';
import 'package:datn_mobile/shared/helper/date_format_helper.dart';
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
      appBar: AppAppBar(title: t.projects.title),
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

    final presentationsAsync = ref.watch(presentationsControllerProvider);

    return presentationsAsync.easyWhen(
      data: (presentations) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          CustomSearchBar(
            hintText: t.projects.presentations.search_presentations,
            onTap: () {
              // Handle tap if needed
            },
            onChanged: (_) {
              // Trigger suggestions builder on change
            },
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
                  if (controller.text.isEmpty) {
                    return [
                      Padding(
                        padding: EdgeInsets.all(Themes.padding.p16),
                        child: Text(
                          t.projects.presentations.search_presentations,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: Themes.fontSize.s14,
                          ),
                        ),
                      ),
                    ];
                  }

                  final query = controller.text.toLowerCase();
                  final filteredPresentations = presentations.where((p) {
                    final title = p.title?.toLowerCase() ?? '';
                    return title.contains(query);
                  }).toList();

                  if (filteredPresentations.isEmpty) {
                    return [
                      Padding(
                        padding: EdgeInsets.all(Themes.padding.p16),
                        child: Column(
                          children: [
                            Icon(
                              LucideIcons.searchX,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No results found for "${controller.text}"',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ];
                  }

                  return filteredPresentations.map((presentation) {
                    return ListTile(
                      leading: const Icon(LucideIcons.presentation),
                      title: Text(presentation.title ?? t.projects.untitled),
                      subtitle: Text(
                        presentation.createdAt != null
                            ? t.projects.created_at(
                                date: DateFormatHelper.formatRelativeDate(
                                  presentation.createdAt!,
                                  ref: ref,
                                ),
                              )
                            : t.projects.unknown_date,
                      ),
                      onTap: () {
                        controller.closeView(presentation.title);
                        // TODO: Navigate to presentation detail
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              t.projects.opening(
                                title:
                                    presentation.title ?? t.projects.untitled,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList();
                },
          ),
          const SizedBox(height: 16),
          // Filter and Sort bar
          FilterAndSortBar(
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(presentationsControllerProvider.notifier)
                    .refresh();
              },
              child: presentations.isEmpty
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
                      itemCount: presentations.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 0),
                      itemBuilder: (context, index) {
                        final presentation = presentations[index];
                        return PresentationTile(
                          presentation: presentation,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  t.projects.opening(
                                    title:
                                        presentation.title ??
                                        t.projects.untitled,
                                  ),
                                ),
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
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormatHelper.formatRelativeDate(date, ref: ref);
  }
}
