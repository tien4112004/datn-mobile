import 'package:flutter/material.dart';

class DropdownField<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T)? itemLabelBuilder;

  const DropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      items: items
          .map(
            (e) => DropdownMenuItem<T>(
              value: e,
              child: Text(itemLabelBuilder?.call(e) ?? '$e'),
            ),
          )
          .toList(),
      onChanged: onChanged,
      menuMaxHeight: 300,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        suffixIcon: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 24,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      style: Theme.of(context).textTheme.bodyMedium,
      dropdownColor: colorScheme.surfaceContainerHighest,
      iconSize: 0, // Hide default icon since we use custom suffixIcon
    );
  }
}
