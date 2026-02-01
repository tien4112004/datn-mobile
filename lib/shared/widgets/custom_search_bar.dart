import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Custom search bar widget with search suggestions support
///
/// This widget provides a consistent search bar experience across the app
/// with support for search suggestions through SearchAnchor
class CustomSearchBar extends StatelessWidget {
  /// The hint text to display when the search field is empty
  final String hintText;

  /// Whether the search field is enabled
  final bool enabled;

  /// Whether the search field should autofocus when displayed
  final bool autoFocus;

  /// Callback to build suggestion widgets based on user input
  ///
  /// Parameters:
  /// - context: The build context
  /// - controller: The search controller for managing search input
  ///
  /// Returns a list of widgets to display as suggestions
  final List<Widget> Function(
    BuildContext context,
    SearchController controller,
  )?
  suggestionsBuilder;

  /// Optional callback when trailing clear button is tapped
  final VoidCallback? onClearTap;

  /// Optional callback when search field text changes
  final ValueChanged<String>? onChanged;

  /// Optional callback when search field is tapped
  final VoidCallback? onTap;

  /// Optional callback when search is submitted (Enter key pressed)
  final ValueChanged<String>? onSubmitted;

  /// Optional initial value for the search field
  final String? initialValue;

  const CustomSearchBar({
    super.key,
    required this.hintText,
    this.suggestionsBuilder,
    this.onClearTap,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.initialValue,
    required this.enabled,
    required this.autoFocus,
  });

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      enabled: enabled,
      builder: (BuildContext context, SearchController controller) {
        // Set initial value if provided
        if (initialValue != null && controller.text.isEmpty) {
          controller.text = initialValue!;
        }

        final colorScheme = Theme.of(context).colorScheme;
        return SearchBar(
          autoFocus: autoFocus,
          constraints: BoxConstraints(
            minWidth: MediaQuery.sizeOf(context).width,
          ),
          backgroundColor: WidgetStatePropertyAll(
            colorScheme.surfaceContainerHighest,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Themes.boxRadiusValue),
            ),
          ),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(2),
          controller: controller,
          padding: WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(
              horizontal: Themes.padding.p12,
              vertical: Themes.padding.p8,
            ),
          ),
          onTap: onTap,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          leading: const Icon(LucideIcons.search, size: 24),
          trailing: controller.text.isNotEmpty
              ? [
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 24),
                    onPressed: () {
                      controller.clear();
                      onClearTap?.call();
                    },
                  ),
                ]
              : null,
          hintText: hintText,
        );
      },
      suggestionsBuilder:
          suggestionsBuilder ??
          (BuildContext context, SearchController controller) {
            return [
              Padding(
                padding: EdgeInsets.all(Themes.padding.p16),
                child: Text(
                  hintText,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: Themes.fontSize.s14,
                  ),
                ),
              ),
            ];
          },
    );
  }
}
