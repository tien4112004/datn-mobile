import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:datn_mobile/shared/widgets/generic_filters_bar.dart';

/// A clickable filter chip that displays a filter's current state
///
/// This widget shows:
/// - Filter icon and label
/// - Selected state with different styling
/// - Chevron down icon to indicate it's tappable
///
/// Used in [GenericFiltersBar] and can be reused elsewhere
class FilterChipButton extends StatelessWidget {
  final BaseFilterConfig filter;
  final VoidCallback? onTap;
  final bool isReadOnly;

  const FilterChipButton({
    super.key,
    required this.filter,
    this.onTap,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = filter.hasSelection;

    return InkWell(
      onTap: isReadOnly ? null : onTap,
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

  static void showFilterPicker(BuildContext context, BaseFilterConfig filter) {
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
              selected: !filter.hasSelection,
              onTap: () {
                Navigator.pop(context);
                filter.onClear();
              },
            ),
            ...filter.buildOptions(context, () {}),
          ],
        ),
      ),
    );
  }
}
