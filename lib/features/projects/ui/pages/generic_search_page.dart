import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:datn_mobile/shared/widget/app_app_bar.dart';
import 'package:datn_mobile/shared/widget/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';

/// Generic resource search page that can be reused for any resource type
///
/// Usage:
/// ```dart
/// GenericResourceSearchPage<PresentationMinimal>(
///   title: 'Search Presentations',
///   resourceAsyncProvider: presentationsControllerProvider,
///   searchPredicate: (item, query) => item.title.toLowerCase().contains(query),
///   itemBuilder: (context, item, onTap) => ListTile(
///     title: Text(item.title),
///     onTap: onTap,
///   ),
/// )
/// ```
class GenericResourceSearchPage<T> extends ConsumerStatefulWidget {
  final String title;

  /// The async provider that returns a list of resources to search
  /// Example: presentationsControllerProvider
  final AsyncNotifierProvider resourceAsyncProvider;

  final bool Function(T item, String query) searchPredicate;
  final Widget Function(BuildContext context, T item, VoidCallback onTap)
  itemBuilder;
  final String Function(T)? getItemTitle;
  final VoidCallback? onItemTap;
  final String emptyStateMessage;
  final String noResultsMessage;

  const GenericResourceSearchPage({
    super.key,
    required this.title,
    required this.resourceAsyncProvider,
    required this.searchPredicate,
    required this.itemBuilder,
    this.getItemTitle,
    this.onItemTap,
    this.emptyStateMessage = 'No resources available',
    this.noResultsMessage = 'No results found',
  });

  @override
  ConsumerState<GenericResourceSearchPage<T>> createState() =>
      _GenericResourceSearchPageState<T>();
}

class _GenericResourceSearchPageState<T>
    extends ConsumerState<GenericResourceSearchPage<T>> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: widget.title,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Search input field using CustomSearchBar
            CustomSearchBar(
              enabled: true,
              autoFocus: true,
              hintText: 'Search ${widget.title.toLowerCase()}',
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              onClearTap: () {
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
            const SizedBox(height: 16),
            // Search results
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final resourcesAsync = ref.watch(
                    widget.resourceAsyncProvider,
                  );

                  return resourcesAsync.easyWhen(
                    data: (state) =>
                        _buildSearchResults(context, state.value as List<T>),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, List<T> resources) {
    // Filter resources based on search query
    final filtered = _searchQuery.isEmpty
        ? resources
        : resources
              .where((item) => widget.searchPredicate(item, _searchQuery))
              .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.searchX, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? widget.emptyStateMessage
                  : '${widget.noResultsMessage} for "$_searchQuery"',
              style: TextStyle(
                fontSize: Themes.fontSize.s16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = filtered[index];
        return widget.itemBuilder(context, item, () {
          widget.onItemTap?.call();
          Navigator.of(context).pop();
        });
      },
    );
  }
}
