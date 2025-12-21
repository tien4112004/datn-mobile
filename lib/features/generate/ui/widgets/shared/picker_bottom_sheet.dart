import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Generic reusable bottom sheet for pickers with scrollable content
/// Displays a title and content with a draggable handle
class PickerBottomSheet extends StatelessWidget {
  final String title;
  final Widget? subTitle;
  final Widget child;

  const PickerBottomSheet({
    super.key,
    required this.title,
    this.subTitle,
    required this.child,
  });

  static void show({
    required BuildContext context,
    required String title,
    Widget? subTitle,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey[900],
                  ),
                ),
                if (subTitle != null) ...[const SizedBox(height: 8), subTitle],
                const SizedBox(height: 8),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey[900],
                ),
              ),
              const SizedBox(height: 8),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
