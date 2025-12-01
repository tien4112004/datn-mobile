import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  const MenuWidget({super.key, required this.items, this.width});

  final List<dynamic> items;
  final double? width;

  @override
  Widget build(BuildContext context) {
    debugPrint('MenuWidget: building menu with width $width');
    return Container(
      width: width ?? 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          return InkWell(
            onTap: item.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(item.icon, size: 20),
                    const SizedBox(width: 12),
                  ],
                  Text(item.label, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MenuItem {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  MenuItem({required this.label, required this.onTap, required this.icon});
}
