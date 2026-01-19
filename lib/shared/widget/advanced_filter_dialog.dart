import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Simple base advanced filter dialog
///
/// This is a simple, reusable modal bottom sheet that can be used
/// for any advanced filtering scenario. It provides:
/// - A draggable sheet with handle
/// - Header with title
/// - Custom content area
/// - Clear all and Done/Apply buttons
///
/// For specific use cases (Questions, Assignments, etc.), create
/// a concrete implementation that manages its own draft state.
void showAdvancedFilterDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  required VoidCallback onClearAll,
  required VoidCallback onApply,
  String applyButtonText = 'Apply Filters',
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => AdvancedFilterDialog(
      title: title,
      content: content,
      onClearAll: onClearAll,
      onApply: onApply,
      applyButtonText: applyButtonText,
    ),
  );
}

/// Base advanced filter dialog widget
class AdvancedFilterDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback onClearAll;
  final VoidCallback onApply;
  final String applyButtonText;

  const AdvancedFilterDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onClearAll,
    required this.onApply,
    required this.applyButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  LucideIcons.slidersHorizontal,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onClearAll,
                  icon: const Icon(LucideIcons.circleX, size: 18),
                  label: const Text('Clear All'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content area
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: content,
            ),
          ),
          // Apply button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    onApply();
                    Navigator.pop(context);
                  },
                  icon: const Icon(LucideIcons.check, size: 20),
                  label: Text(applyButtonText),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
