import 'package:flutter/material.dart';
import 'package:flex_dropdown/flex_dropdown.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'menu_widget.dart';
import 'dropdown_button.dart';

/// Reusable presentation dropdown field using flex_dropdown
/// Provides consistent styling and behavior for dropdown selections
class PresentationDropdownField extends StatefulWidget {
  final String label;
  final List<String> items;
  final String currentValue;
  final ValueChanged<String> onChanged;
  final IconData? icon;
  final String? displayText;

  const PresentationDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.currentValue,
    required this.onChanged,
    this.icon,
    this.displayText,
  });

  @override
  State<PresentationDropdownField> createState() =>
      _PresentationDropdownFieldState();
}

class _PresentationDropdownFieldState extends State<PresentationDropdownField> {
  late final OverlayPortalController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OverlayPortalController();
  }

  @override
  void dispose() {
    _controller.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawFlexDropDown(
      controller: _controller,
      buttonBuilder: (context, onTap) {
        return DropdownButtonWidget(
          onTap: onTap,
          items: widget.items,
          onChanged: (_) {},
          label: widget.label,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.displayText ?? widget.currentValue,
                  style: const TextStyle(fontSize: 14),
                ),
                const Spacer(flex: 1),
                const Icon(LucideIcons.chevronDown, size: 16),
              ],
            ),
          ),
        );
      },
      menuBuilder: (context, width) => MenuWidget(
        width: width,
        items: widget.items.map((item) {
          debugPrint('Creating MenuWidget for $item with width $width');
          return MenuItem(
            icon: widget.icon,
            label: item,
            onTap: () {
              widget.onChanged(item);
              _controller.hide();
            },
          );
        }).toList(),
      ),
    );
  }
}
