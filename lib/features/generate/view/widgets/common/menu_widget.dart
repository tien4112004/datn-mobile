import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  const MenuWidget({super.key, required this.items, this.width});

  final List<dynamic> items;
  final double? width;

  static const double _itemHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    debugPrint('MenuWidget: building menu with width $width');
    final double calculatedHeight = _calculateTotalHeight() > 300
        ? 300
        : _calculateTotalHeight();

    return Container(
      width: width ?? 200,
      height: calculatedHeight,
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
      child: SingleChildScrollView(
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
      ),
    );
  }

  double _calculateTotalHeight() {
    if (items.isEmpty) return 0;
    // Total = (Height of one item * number of items) + top/bottom borders
    return items.length * _itemHeight;
  }
}

class MenuItem {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  MenuItem({required this.label, required this.onTap, required this.icon});
}
