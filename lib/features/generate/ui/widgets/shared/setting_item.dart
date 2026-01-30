import 'package:AIPrimary/shared/utils/theme_utils.dart';
import 'package:flutter/material.dart';

/// Internal widget for displaying a labeled setting field.
class SettingItem extends StatelessWidget {
  final String label;
  final Widget child;

  const SettingItem({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
