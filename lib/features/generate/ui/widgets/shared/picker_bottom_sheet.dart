import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Generic reusable bottom sheet for pickers with scrollable content
/// Displays a title and content with a draggable handle
class PickerBottomSheet extends StatefulWidget {
  final String title;
  final String? subTitle;
  final Widget child;
  final Widget? saveButton;

  const PickerBottomSheet({
    super.key,
    required this.title,
    this.subTitle,
    required this.child,
    this.saveButton,
  });

  static void show({
    required BuildContext context,
    required String title,
    String? subTitle,
    required Widget child,
    Widget? saveButton,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => PickerBottomSheet(
        title: title,
        subTitle: subTitle,
        saveButton: saveButton,
        child: child,
      ),
    );
  }

  @override
  State<PickerBottomSheet> createState() => _PickerBottomSheetState();
}

class _PickerBottomSheetState extends State<PickerBottomSheet> {
  final _scrollKey = GlobalKey();
  final _controller = DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (kDebugMode) {
      print('Is Save button null: ${widget.saveButton == null}');
    }
    return DraggableScrollableSheet(
      maxChildSize: 0.9,
      key: _scrollKey,
      controller: _controller,
      snap: true,
      snapSizes: [0.5, 0.9],
      expand: true,
      builder: (context, scrollController) {
        return _buildContent(isDark, scrollController);
      },
    );
  }

  Widget _buildContent(bool isDark, ScrollController scrollController) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Stack(
          children: [
            CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverList.list(
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[600] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey[900],
                      ),
                    ),
                    if (widget.subTitle != null) ...[
                      const SizedBox(height: 8),
                      DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                        child: Text(widget.subTitle!),
                      ),
                    ],
                    widget.child,
                  ],
                ),
              ],
            ),
            if (widget.saveButton != null)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: widget.saveButton!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
