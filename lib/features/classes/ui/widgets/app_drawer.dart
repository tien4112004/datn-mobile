import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Navigation drawer following Google Classroom design.
///
/// Shows Classes, Calendar, and Settings navigation items.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            _buildHeader(context, colorScheme),
            const Divider(height: 1),
            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildNavItem(
                    context,
                    icon: LucideIcons.layoutGrid,
                    label: 'Classes',
                    isSelected: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildNavItem(
                    context,
                    icon: LucideIcons.calendarDays,
                    label: 'Calendar',
                    onTap: () {
                      Navigator.pop(context);
                      context.router.push(PlaceholderRouteSchedule());
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(),
                  ),
                  _buildNavItem(
                    context,
                    icon: LucideIcons.settings,
                    label: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      context.router.push(const SettingRoute());
                    },
                  ),
                ],
              ),
            ),
            // Version info at bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'EduClass v1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App logo/icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              LucideIcons.graduationCap,
              color: colorScheme.onPrimary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'EduClass',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Learning Management System',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: '$label navigation item${isSelected ? ', selected' : ''}',
      button: true,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
        selected: isSelected,
        selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        onTap: onTap,
      ),
    );
  }
}
