import 'package:datn_mobile/features/projects/states/controller_provider.dart';
import 'package:datn_mobile/features/projects/ui/widgets/presentation/presentation_list_item.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ResourceListView extends ConsumerStatefulWidget {
  final String resourceType;
  final VoidCallback onBack;

  const ResourceListView({
    super.key,
    required this.resourceType,
    required this.onBack,
  });

  @override
  ConsumerState<ResourceListView> createState() => _ResourceListViewState();
}

class _ResourceListViewState extends ConsumerState<ResourceListView> {
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
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: widget.onBack,
              icon: const Icon(LucideIcons.arrowLeft),
              label: Text(t.projects.back_to_resources),
            ),
          ],
        ),
      );
    }

    return ref
        .watch(presentationsControllerProvider)
        .easyWhen(
          data: (presentationListState) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft),
                    onPressed: widget.onBack,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.projects.your_presentations,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Filter and Sort bar
              Row(
                children: [
                  // Filter button group - left side
                  Expanded(
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
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
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: presentationListState.value.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final presentation =
                                presentationListState.value[index];
                            return PresentationListItem(
                              presentation: presentation,
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
  }
}
