import 'package:flex_dropdown/flex_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

class FlexDropdownField<T> extends ConsumerWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;

  /// Optional builder for the selected item label (used if itemBuilder is null)
  final String Function(T)? itemLabelBuilder;

  /// Optional custom builder for the dropdown button content
  final Widget Function(BuildContext, VoidCallback)? buttonBuilder;

  /// Optional builder for rendering items in both the list and the selected view
  final Widget Function(BuildContext, T)? itemBuilder;

  final _controller = OverlayPortalController();

  FlexDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabelBuilder,
    this.buttonBuilder,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RawFlexDropDown(
      controller: _controller,
      buttonBuilder:
          buttonBuilder ??
          (context, openMenu) {
            final selectedItem = value;
            return SizedBox(
              width: double.infinity,
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                child: InkWell(
                  onTap: openMenu,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (selectedItem != null && itemBuilder != null)
                          itemBuilder!(context, selectedItem)
                        else
                          Text(
                            selectedItem != null
                                ? itemLabelBuilder?.call(selectedItem) ??
                                      '$selectedItem'
                                : t
                                      .shared
                                      .widgets
                                      .flexDropdownField
                                      .selectPlaceholder,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 24,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
      menuBuilder: (context, width) {
        return Material(
          color: isDark ? Colors.grey[850] : Colors.white,
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: width,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: items.map((item) {
                  return InkWell(
                    onTap: () {
                      onChanged(item);
                      _controller.hide();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: itemBuilder != null
                          ? itemBuilder!(context, item)
                          : Text(
                              itemLabelBuilder?.call(item) ?? '$item',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
