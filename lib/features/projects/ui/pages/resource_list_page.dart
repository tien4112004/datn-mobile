import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/controllers/controller_provider.dart';
import 'package:datn_mobile/features/projects/ui/widgets/presentation/presentation_list_item.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
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
      appBar: AppBar(title: Text(t.projects.title)),
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
          // Header
          Text(
            t.projects.your_presentations,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Search bar
          SearchAnchor(
            builder: (BuildContext context, SearchController controller) {
              return SearchBar(
                controller: controller,
                padding: WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: Themes.padding.p12),
                ),
                onTap: () {
                  controller.openView();
                },
                onChanged: (_) {
                  controller.openView();
                },
                leading: const Icon(LucideIcons.search),
                trailing: controller.text.isNotEmpty
                    ? [
                        IconButton(
                          icon: const Icon(LucideIcons.x),
                          onPressed: () {
                            controller.clear();
                          },
                        ),
                      ]
                    : null,
                hintText: t.projects.search_presentations,
              );
            },
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
                  if (controller.text.isEmpty) {
                    return [
                      Padding(
                        padding: EdgeInsets.all(Themes.padding.p16),
                        child: Text(
                          t.projects.search_presentations,
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
                                date: _formatDate(presentation.createdAt!),
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
          Row(
            children: [
              // Filter button group with horizontal scroll - left side
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Main filter button
                      OutlinedButton(
                        onPressed: () {
                          // TODO: Implement filter functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(t.projects.filter_coming_soon),
                            ),
                          );
                        },
                        child: const Icon(LucideIcons.listFilter),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Clear status filter
                        },
                        icon: const Icon(LucideIcons.x, size: 16),
                        label: const Text('Active'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: Themes.padding.p12,
                            vertical: Themes.padding.p8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Add more filter chips here as needed
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Sort dropdown - right side
              PopupMenuButton<String>(
                initialValue: _sortOption,
                onSelected: (String value) {
                  setState(() {
                    _sortOption = value;
                  });
                  // TODO: Implement sort functionality
                },
                itemBuilder: (BuildContext context) => _sortOptions
                    .map(
                      (option) => PopupMenuItem<String>(
                        value: option,
                        child: Text(option),
                      ),
                    )
                    .toList(),
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(LucideIcons.arrowUpDown, size: 16),
                  label: Text(
                    _sortOption,
                    style: const TextStyle(fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: Themes.padding.p12,
                      vertical: Themes.padding.p8,
                    ),
                  ),
                ),
              ),
            ],
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
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final presentation = presentations[index];
                        return PresentationListItem(presentation: presentation);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final t = ref.read(translationsPod);

    if (difference.inMinutes < 60) {
      return t.projects.minutes_ago(count: difference.inMinutes);
    } else if (difference.inHours < 24) {
      return t.projects.hours_ago(count: difference.inHours);
    } else if (difference.inDays == 1) {
      return t.projects.yesterday;
    } else if (difference.inDays < 7) {
      return t.projects.days_ago(count: difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
