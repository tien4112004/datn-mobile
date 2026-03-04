import 'package:AIPrimary/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Formats a DateTime as dd/MM/yyyy HH:mm
String _fmt(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

/// Availability window section: availableFrom, dueDate, availableUntil
class DueDateSection extends StatelessWidget {
  final DateTime? availableFrom;
  final DateTime? dueDate;
  final DateTime? availableUntil;
  final bool isDisabled;
  final VoidCallback onPickAvailableFrom;
  final VoidCallback onPickDueDate;
  final VoidCallback onPickAvailableUntil;
  final Translations translations;

  const DueDateSection({
    super.key,
    required this.availableFrom,
    required this.dueDate,
    required this.availableUntil,
    required this.isDisabled,
    required this.onPickAvailableFrom,
    required this.onPickDueDate,
    required this.onPickAvailableUntil,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = translations.classes.postUpsert;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Row(
                children: [
                  Icon(
                    LucideIcons.calendarClock,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.availabilityWindow,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Available From row
              _DateRow(
                icon: LucideIcons.calendarCheck,
                iconColor: colorScheme.tertiary,
                label: t.availableFrom,
                value: availableFrom != null ? _fmt(availableFrom!) : null,
                hint: t.availableFromHint,
                isDisabled: isDisabled,
                onTap: onPickAvailableFrom,
                theme: theme,
                colorScheme: colorScheme,
              ),

              Divider(
                height: 16,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),

              // Due Date row
              _DateRow(
                icon: LucideIcons.calendarX2,
                iconColor: colorScheme.error,
                label: t.dueDate,
                value: dueDate != null ? _fmt(dueDate!) : null,
                hint: t.dueDateHint,
                isDisabled: isDisabled,
                onTap: onPickDueDate,
                theme: theme,
                colorScheme: colorScheme,
              ),

              Divider(
                height: 16,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),

              // Available Until row
              _DateRow(
                icon: LucideIcons.calendarMinus,
                iconColor: colorScheme.secondary,
                label: t.availableUntil,
                value: availableUntil != null ? _fmt(availableUntil!) : null,
                hint: t.availableUntilHint,
                isDisabled: isDisabled,
                onTap: onPickAvailableUntil,
                theme: theme,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final String hint;
  final bool isDisabled;
  final VoidCallback onTap;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _DateRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.hint,
    required this.isDisabled,
    required this.onTap,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value ?? hint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: value != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontWeight: value != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
