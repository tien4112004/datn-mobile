import 'package:flex_dropdown/flex_dropdown.dart';
import 'package:flutter/material.dart';

class FlexDropdownField<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T)? itemLabelBuilder;
  final Widget Function(BuildContext, VoidCallback)? buttonBuilder;

  final _controller = OverlayPortalController();

  FlexDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabelBuilder,
    this.buttonBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RawFlexDropDown(
      controller: _controller,
      buttonBuilder:
          buttonBuilder ??
          (context, openMenu) {
            final selectedItem = value;
            final label = selectedItem != null
                ? itemLabelBuilder?.call(selectedItem) ?? '$selectedItem'
                : 'Select';
            return SizedBox(
              width: double.infinity,

              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black12),
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
                        Text(
                          label,
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
                  final label = itemLabelBuilder?.call(item) ?? '$item';
                  return ListTile(
                    title: Text(label),
                    onTap: () {
                      onChanged(item);
                      _controller.hide();
                    },
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
