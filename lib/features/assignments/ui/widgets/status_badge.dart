import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/utils/enum_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StatusBadge extends ConsumerWidget {
  final AssignmentStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = _getStatusConfig(status);
    final t = ref.watch(translationsPod);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 4),
          Text(
            status.localizedName(t),
            style: theme.textTheme.labelSmall?.copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.draft:
        return _StatusConfig(color: Colors.grey, icon: LucideIcons.file);
      case AssignmentStatus.generating:
        return _StatusConfig(
          color: Themes.primaryColor,
          icon: LucideIcons.loader,
        );
      case AssignmentStatus.completed:
        return _StatusConfig(
          color: Colors.green,
          icon: LucideIcons.circleCheck,
        );
      case AssignmentStatus.error:
        return _StatusConfig(color: Colors.red, icon: LucideIcons.circleX);
      case AssignmentStatus.archived:
        return _StatusConfig(color: Colors.orange, icon: LucideIcons.archive);
    }
  }
}

class _StatusConfig {
  final Color color;
  final IconData icon;

  _StatusConfig({required this.color, required this.icon});
}
