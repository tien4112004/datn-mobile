import 'package:flutter/material.dart';

class DropdownButtonWidget extends StatelessWidget {
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onTap;
  final Widget? child;
  final double height;
  final String label;

  const DropdownButtonWidget({
    super.key,
    required this.items,
    required this.onChanged,
    this.onTap,
    this.child,
    this.height = 36.0,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: height,
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.black12),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: Center(child: child),
            ),
          ),
        ),
      ],
    );
  }
}
