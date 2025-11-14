import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/projects/domain/entity/resource_type.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ResourceTypeCard extends StatelessWidget {
  final ResourceType resourceType;
  final VoidCallback onTap;

  const ResourceTypeCard({
    super.key,
    required this.resourceType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: Themes.boxRadius,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: resourceType.color.withValues(alpha: 0.1),
                borderRadius: Themes.boxRadius,
              ),
              child: Icon(
                resourceType.icon,
                color: resourceType.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              resourceType.label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}
