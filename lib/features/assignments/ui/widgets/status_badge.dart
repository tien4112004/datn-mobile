import 'package:datn_mobile/features/assignments/domain/entity/assignment_enums.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StatusBadge extends StatelessWidget {
  final AssignmentStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getStatusConfig(status);

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
            status.displayName,
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
        return _StatusConfig(color: Colors.blue, icon: LucideIcons.loader);
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
