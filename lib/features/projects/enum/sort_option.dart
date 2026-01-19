import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';

/// Sort options for project resources (images, presentations, etc.)
enum SortOption {
  dateCreatedAsc,
  dateCreatedDesc,
  nameAsc,
  nameDesc;

  /// Get the display name for this sort option using translations
  String displayName(Translations t) {
    switch (this) {
      case SortOption.dateCreatedAsc:
        return t.projects.common_list.sort_date_created_asc;
      case SortOption.dateCreatedDesc:
        return t.projects.common_list.sort_date_created_desc;
      case SortOption.nameAsc:
        return t.projects.common_list.sort_name_asc;
      case SortOption.nameDesc:
        return t.projects.common_list.sort_name_desc;
    }
  }

  /// Get the icon for this sort option
  IconData get icon {
    switch (this) {
      case SortOption.dateCreatedAsc:
      case SortOption.dateCreatedDesc:
        return LucideIcons.calendar;
      case SortOption.nameAsc:
      case SortOption.nameDesc:
        return LucideIcons.arrowUpDown;
    }
  }

  /// Convert to API value string
  String toApiValue() {
    switch (this) {
      case SortOption.dateCreatedAsc:
        return 'asc';
      case SortOption.dateCreatedDesc:
        return 'desc';
      case SortOption.nameAsc:
        return 'asc';
      case SortOption.nameDesc:
        return 'desc';
    }
  }
}
