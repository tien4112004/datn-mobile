import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FilterDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String label;
  final Function(String?) onChanged;
  final bool isActive;

  const FilterDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String?>(value: null, child: Text(label)),
        ...items.map(
          (item) => PopupMenuItem<String?>(value: item, child: Text(item)),
        ),
      ],
      child: OutlinedButton.icon(
        iconAlignment: IconAlignment.end,
        icon: const Icon(LucideIcons.chevronDown, size: 16),
        onPressed: null,
        label: Text(value ?? label, style: const TextStyle(fontSize: 14)),
        style: OutlinedButton.styleFrom(
          backgroundColor: isActive
              ? Colors.blue.shade100
              : Colors.grey.shade100,
          padding: EdgeInsets.symmetric(
            horizontal: Themes.padding.p12,
            vertical: Themes.padding.p8,
          ),
          side: BorderSide.none,
        ),
      ),
    );
  }
}
