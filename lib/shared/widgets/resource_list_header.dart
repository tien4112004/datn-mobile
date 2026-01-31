import 'dart:async';

import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:AIPrimary/shared/widgets/flex_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Unified resource list header with search, sort, and view toggle
///
/// This widget provides a consistent header for all resource list pages:
/// - Integrated search field with real-time filtering
/// - Sort dropdown (date modified/created, name A-Z/Z-A)
/// - Optional grid/list view toggle
///
/// Usage:
/// ```dart
/// ResourceListHeader(
///   searchQuery: _searchQuery,
///   onSearchChanged: (query) => setState(() => _searchQuery = query),
///   selectedSort: _sortOption,
///   sortOptions: _sortOptions,
///   onSortChanged: (sort) => setState(() => _sortOption = sort),
///   showViewToggle: true,
///   isGridView: _isGridView,
///   onViewToggle: () => setState(() => _isGridView = !_isGridView),
/// )
/// ```
class ResourceListHeader extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String selectedSort;
  final List<String> sortOptions;
  final ValueChanged<String> onSortChanged;
  final bool showViewToggle;
  final bool isGridView;
  final VoidCallback? onViewToggle;
  final String? searchHint;
  final Translations t;

  const ResourceListHeader({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedSort,
    required this.sortOptions,
    required this.onSortChanged,
    this.showViewToggle = false,
    this.isGridView = false,
    this.onViewToggle,
    this.searchHint,
    required this.t,
  });

  @override
  State<ResourceListHeader> createState() => _ResourceListHeaderState();
}

class _ResourceListHeaderState extends State<ResourceListHeader> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounce?.cancel();

    // Start new timer - only call the callback after 500ms of no typing
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search field
        TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: widget.searchHint ?? 'Search...',
            hintStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: Themes.fontSize.s14,
            ),
            prefixIcon: const Icon(LucideIcons.search, size: 20),
            suffixIcon: widget.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      widget.onSearchChanged('');
                      _searchFocusNode.unfocus();
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Themes.boxRadiusValue),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Themes.padding.p12,
              vertical: Themes.padding.p12,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Sort and View Toggle Row
        Row(
          children: [
            // Sort button
            Expanded(child: _buildSortButton()),

            // View toggle (grid/list)
            if (widget.showViewToggle && widget.onViewToggle != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  widget.isGridView ? LucideIcons.list : LucideIcons.layoutGrid,
                  size: 24,
                ),
                onPressed: widget.onViewToggle,
                tooltip: widget.isGridView ? 'List view' : 'Grid view',
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSortButton() {
    return FlexDropdownField<String>(
      value: widget.selectedSort,
      items: widget.sortOptions,
      onChanged: widget.onSortChanged,
      itemLabelBuilder: (item) => item,
      buttonBuilder: (context, openMenu) {
        return InkWell(
          onTap: openMenu,
          borderRadius: BorderRadius.circular(Themes.boxRadiusValue),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Themes.padding.p12,
              vertical: Themes.padding.p12,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(Themes.boxRadiusValue),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.arrowUpDown, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      widget.selectedSort,
                      style: TextStyle(fontSize: Themes.fontSize.s14),
                    ),
                  ],
                ),
                const Icon(LucideIcons.chevronDown, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}
