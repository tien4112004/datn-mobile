import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SortButton extends StatelessWidget {
  final String selectedSort;
  final List<String> sortOptions;
  final Function(String) onSortChanged;
  final Translations t;

  const SortButton({
    super.key,
    required this.selectedSort,
    required this.sortOptions,
    required this.onSortChanged,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: selectedSort,
      onSelected: onSortChanged,
      itemBuilder: (BuildContext context) => sortOptions
          .map(
            (option) =>
                PopupMenuItem<String>(value: option, child: Text(option)),
          )
          .toList(),
      child: OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(LucideIcons.arrowUpDown, size: 16),
        label: Text(t.projects.sort, style: const TextStyle(fontSize: 14)),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.grey.shade100,
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
