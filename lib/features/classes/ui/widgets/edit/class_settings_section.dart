import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Section for managing class settings.
///
/// Contains:
/// - Active/Inactive toggle with visual feedback
/// - Join code display (read-only)
/// - Creation and update timestamps
///
/// Features Material Design 3 styling with:
/// - Interactive switch with haptic feedback
/// - Clear status indicators
/// - Information cards
/// - Accessible design
class ClassSettingsSection extends ConsumerWidget {
  final bool isActive;
  final String? joinCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ValueChanged<bool> onActiveChanged;

  const ClassSettingsSection({
    super.key,
    required this.isActive,
    required this.joinCode,
    required this.createdAt,
    required this.updatedAt,
    required this.onActiveChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.settings,
                size: 20,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              t.classes.settingsSection.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Active status toggle
        _buildActiveStatusCard(context, t),

        const SizedBox(height: 16),

        // Join code display
        if (joinCode != null) _buildJoinCodeCard(context, t),
      ],
    );
  }

  Widget _buildActiveStatusCard(BuildContext context, dynamic t) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: t.classes.settingsSection.statusToggle,
      toggled: isActive,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isActive
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.primaryContainer
                      : colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isActive ? LucideIcons.circleCheck : LucideIcons.circleX,
                  size: 24,
                  color: isActive
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onErrorContainer,
                ),
              ),

              const SizedBox(width: 16),

              // Status text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.classes.settingsSection.statusLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isActive
                          ? t.classes.settingsSection.activeDescription
                          : t.classes.settingsSection.inactiveDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Toggle switch
              Switch(
                value: isActive,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  onActiveChanged(value);
                },
                activeTrackColor: colorScheme.primary.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinCodeCard(BuildContext context, dynamic t) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Join code icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                LucideIcons.key,
                size: 24,
                color: colorScheme.onTertiaryContainer,
              ),
            ),

            const SizedBox(width: 16),

            // Join code info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.classes.settingsSection.joinCodeLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    joinCode!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.classes.settingsSection.joinCodeDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Copy button
            Semantics(
              label: t.classes.settingsSection.copyJoinCode,
              button: true,
              child: IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: joinCode!));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.classes.settingsSection.joinCodeCopied),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.copy),
                tooltip: t.classes.settingsSection.copyJoinCode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
