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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.grey[700]! : const Color(0xFFE6E6E6);

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor),
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
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        suffixIcon: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 24,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      style: Theme.of(context).textTheme.bodyMedium,
      dropdownColor: isDark ? Colors.grey[850] : Colors.white,
      iconSize: 0, // Hide default icon since we use custom suffixIcon
    );
  }
}
