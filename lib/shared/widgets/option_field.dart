import 'package:AIPrimary/shared/widgets/flex_dropdown_field.dart';
import 'package:flutter/material.dart';

/// Base class for all option field types
abstract class OptionFieldConfig {
  final String label;
  final String? key;

  const OptionFieldConfig({required this.label, this.key});

  Widget build(BuildContext context);

  /// Helper method to build a labeled field layout
  Widget buildWithLabel(BuildContext context, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// Selection/Dropdown option field
class SelectionOption extends OptionFieldConfig {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const SelectionOption({
    required super.label,
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return buildWithLabel(
      context,
      FlexDropdownField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

/// Text input option field
class TextInputOption extends OptionFieldConfig {
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const TextInputOption({
    required super.label,
    super.key,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return buildWithLabel(
      context,
      TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
          filled: true,
          fillColor: isDark ? Colors.grey[850] : const Color(0xFFF9FAFB),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[700]! : const Color(0xFFE6E6E6),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[700]! : const Color(0xFFE6E6E6),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.primary),
          ),
        ),
      ),
    );
  }
}

/// Number input option field
class NumberInputOption extends OptionFieldConfig {
  final TextEditingController controller;
  final String? hint;
  final int? min;
  final int? max;

  const NumberInputOption({
    required super.label,
    super.key,
    required this.controller,
    this.hint,
    this.min,
    this.max,
  });

  @override
  Widget build(BuildContext context) {
    return TextInputOption(
      label: label,
      key: key,
      controller: controller,
      hint: hint,
      keyboardType: TextInputType.number,
    ).build(context);
  }
}

/// Switch/Toggle option field
class SwitchOption extends OptionFieldConfig {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? description;

  const SwitchOption({
    required super.label,
    super.key,
    required this.value,
    required this.onChanged,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 2),
                Text(
                  description!,
                  style: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

/// Slider option field
class SliderOption extends OptionFieldConfig {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String Function(double)? valueFormatter;

  const SliderOption({
    required super.label,
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            Text(
              valueFormatter?.call(value) ?? value.toStringAsFixed(1),
              style: TextStyle(
                color: cs.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Empty/Spacer option field (for layout purposes)
class EmptyOption extends OptionFieldConfig {
  const EmptyOption({super.key}) : super(label: '');

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// Helper class to build option rows with 1 or 2 fields
class OptionRow {
  final OptionFieldConfig first;
  final OptionFieldConfig? second;

  const OptionRow({required this.first, this.second});

  Widget build(BuildContext context) {
    if (second == null) {
      return first.build(context);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first.build(context)),
        const SizedBox(width: 12),
        Expanded(child: second!.build(context)),
      ],
    );
  }
}
