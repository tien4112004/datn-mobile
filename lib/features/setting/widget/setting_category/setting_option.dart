import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingOption extends StatelessWidget {
  const SettingOption({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    required this.onPressed,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: Themes.boxRadius,
        ),
        child: Icon(
          icon ?? LucideIcons.settings,
          size: 24,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            )
          : null,
      trailing: trailing ?? const Icon(LucideIcons.chevronRight, size: 16),
      onTap: onPressed,
    );
  }
}
