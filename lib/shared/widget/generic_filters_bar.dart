import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:datn_mobile/shared/widget/filter_chip_button.dart';

/// Base class for type-erased filter configuration
abstract class BaseFilterConfig {
  String get label;
  IconData get icon;
  bool get hasSelection;
  String get displayLabel;
  String get allLabel;
  IconData get allIcon;

  /// Build the options list for the picker
  List<Widget> buildOptions(BuildContext context, VoidCallback onItemTapped);

  /// Handle clearing the filter
  void onClear();
}

/// Configuration for a single filter with type safety preserved
class FilterConfig<T> implements BaseFilterConfig {
  @override
  final String label;
  @override
  final IconData icon;
  final T? selectedValue;
  final List<T> options;
  final String Function(T) displayNameBuilder;
  final IconData Function(T)? iconBuilder;
  final ValueChanged<T?> onChanged;
  @override
  final String allLabel;
  @override
  final IconData allIcon;

  const FilterConfig({
    required this.label,
    required this.icon,
    required this.selectedValue,
    required this.options,
    required this.displayNameBuilder,
    this.iconBuilder,
    required this.onChanged,
    required this.allLabel,
    this.allIcon = LucideIcons.list,
  });

  @override
  bool get hasSelection => selectedValue != null;

  @override
  String get displayLabel {
    if (selectedValue == null) return allLabel;
    return displayNameBuilder(selectedValue as T);
  }

  @override
  List<Widget> buildOptions(BuildContext context, VoidCallback onItemTapped) {
    return options.map<Widget>((option) {
      final optionIcon = iconBuilder?.call(option) ?? icon;
      return ListTile(
        leading: Icon(optionIcon),
        title: Text(displayNameBuilder(option)),
        selected: selectedValue == option,
        onTap: () {
          Navigator.pop(context);
          onChanged(option);
        },
      );
    }).toList();
  }

  @override
  void onClear() {
    onChanged(null);
  }
}

/// Generic filters bar widget that supports multiple filter types
///
/// This widget provides a consistent filter UI across all pages:
/// - Horizontal scrollable filter chips
/// - Modal bottom sheet pickers for filter selection
/// - Clear filters button when any filter is active
/// - Support for any enum or value type through generics
///
/// Usage:
/// ```dart
/// GenericFiltersBar(
///   filters: [
///     FilterConfig<AssignmentStatus>(
///       label: 'Status',
///       icon: LucideIcons.info,
///       selectedValue: _selectedStatus,
///       options: AssignmentStatus.values,
///       displayNameBuilder: (status) => status.displayName,
///       iconBuilder: (status) => _getStatusIcon(status),
///       onChanged: (status) => setState(() => _selectedStatus = status),
///       allLabel: 'All Status',
///       allIcon: LucideIcons.list,
///     ),
///   ],
///   onClearFilters: () => setState(() { /* clear all */ }),
/// )
/// ```
class GenericFiltersBar extends StatelessWidget {
  final List<BaseFilterConfig> filters;
  final VoidCallback onClearFilters;
  final bool isReadOnly;
  final bool useWrap;
  final List<Widget> trailing;

  const GenericFiltersBar({
    super.key,
    required this.filters,
    required this.onClearFilters,
    this.isReadOnly = false,
    this.useWrap = false,
    this.trailing = const [],
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = filters.any((filter) => filter.hasSelection);

    final children = [
      ...filters.map((filter) {
        final chip = FilterChipButton(
          filter: filter,
          onTap: () => FilterChipButton.showFilterPicker(context, filter),
          isReadOnly: isReadOnly,
        );

        if (useWrap) return chip;

        return Padding(padding: const EdgeInsets.only(right: 8), child: chip);
      }),
      ...trailing,
      if (hasFilters && !isReadOnly)
        TextButton.icon(
          onPressed: onClearFilters,
          icon: const Icon(LucideIcons.x, size: 14),
          label: const Text('Clear'),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
        ),
    ];

    if (useWrap) {
      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: children),
      ),
    );
  }
}
