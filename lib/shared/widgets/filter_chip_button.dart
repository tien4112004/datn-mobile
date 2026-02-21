import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/widgets/generic_filters_bar.dart';

/// A clickable filter chip that displays a filter's current state
///
/// This widget shows:
/// - Filter icon and label
/// - Selected state with different styling
/// - Chevron down icon to indicate it's tappable
///
/// Used in [GenericFiltersBar] and can be reused elsewhere
class FilterChipButton extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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

  static void showFilterPicker(
    BuildContext context,
    BaseFilterConfig filter,
    WidgetRef ref,
  ) {
    final t = ref.read(translationsPod);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                t.common.filterBy(label: filter.label),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.list),
              title: Text(t.common.all),
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
