import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Configuration for a single filter
class FilterConfig<T> {
  final String label;
  final IconData icon;
  final T? selectedValue;
  final List<T> options;
  final String Function(dynamic) displayNameBuilder;
  final IconData Function(dynamic)? iconBuilder;
  final ValueChanged<T?> onChanged;
  final String allLabel;
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

  bool get hasSelection => selectedValue != null;

  String get displayLabel {
    if (selectedValue == null) return allLabel;
    return displayNameBuilder(selectedValue);
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
  final List<FilterConfig<dynamic>> filters;
  final VoidCallback onClearFilters;

  const GenericFiltersBar({
    super.key,
    required this.filters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasFilters = filters.any((filter) => filter.hasSelection);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Icon(
              LucideIcons.settings,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Filters:',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            ...filters.map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(context: context, filter: filter),
              );
            }),
            if (hasFilters)
              TextButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(LucideIcons.x, size: 14),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required FilterConfig<dynamic> filter,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = filter.hasSelection;

    return InkWell(
      onTap: () => _showFilterPicker(context, filter),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filter.icon,
              size: 14,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              filter.displayLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              LucideIcons.chevronDown,
              size: 14,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterPicker(BuildContext context, FilterConfig<dynamic> filter) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Filter by ${filter.label}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: Icon(filter.allIcon),
              title: Text(filter.allLabel),
              selected: filter.selectedValue == null,
              onTap: () {
                filter.onChanged(null);
                Navigator.pop(context);
              },
            ),
            ...filter.options.map<Widget>((option) {
              final icon = filter.iconBuilder?.call(option) ?? filter.icon;
              return ListTile(
                leading: Icon(icon),
                title: Text(filter.displayNameBuilder(option)),
                selected: filter.selectedValue == option,
                onTap: () {
                  filter.onChanged(option);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
