import 'package:flutter/material.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Stats Section - Displays difficulty and success rate statistics
///
/// Features:
/// - Two-column grid layout for stats cards
/// - Circular icon containers with custom colors
/// - Uppercase labels with proper letter spacing
/// - Responsive layout with 16px gap between cards
class StatsSection extends StatelessWidget {
  final BaseQuestion question;

  const StatsSection({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          // Difficulty Card
          Expanded(
            child: _StatCard(
              icon: LucideIcons.gauge,
              iconColor: const Color(0xFFEA580C),
              iconBackgroundColor: const Color(0xFFFED7AA),
              label: 'DIFFICULTY',
              value: question.difficulty.displayName,
            ),
          ),
          const SizedBox(width: 16),
          // Success Rate Card (mock data for now)
          const Expanded(
            child: _StatCard(
              icon: LucideIcons.trendingUp,
              iconColor: Color(0xFF9333EA),
              iconBackgroundColor: Color(0xFFE9D5FF),
              label: 'SUCCESS RATE',
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual Stat Card - Reusable component for displaying a single statistic
///
/// Features:
/// - Material 3 card styling
/// - Circular icon container with custom colors
/// - Label and value with proper typography
/// - Consistent 16px padding
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String label;
  final String? value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.label,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          // Label & Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                value != null
                    ? Text(
                        value!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
