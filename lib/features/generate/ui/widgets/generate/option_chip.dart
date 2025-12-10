import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A clickable chip widget for displaying options like slide count, language, or model.
///
/// Extracted from PresentationGeneratePage to reduce duplication and improve reusability.
class OptionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const OptionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: ThemeDecorations.chipDecoration(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.isDarkMode ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: context.secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
