import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/projects/enum/resource_type.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ResourceTypeCard extends ConsumerWidget {
  final ResourceType resourceType;
  final VoidCallback onTap;

  const ResourceTypeCard({
    super.key,
    required this.resourceType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    return InkWell(
      onTap: onTap,
      borderRadius: Themes.boxRadius,
      splashColor: resourceType.color.withValues(alpha: 0.1),
      highlightColor: resourceType.color.withValues(alpha: 0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        constraints: const BoxConstraints(minHeight: 64),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: Themes.boxRadius,
                border: Border.all(
                  color: resourceType.color.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                resourceType.icon,
                color: resourceType.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                resourceType.getLabel(t),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }
}
