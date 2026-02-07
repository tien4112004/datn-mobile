import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

class TodayWorksSection extends ConsumerWidget {
  const TodayWorksSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.todayWorks,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 16),
        _buildWorkItem(
          context,
          icon: LucideIcons.messageSquare,
          iconColor: Colors.green,
          iconBgColor: Colors.green.shade50,
          title: t.parentTeacherMeetings,
          time: t.todayAt(time: '3:00 PM'),
        ),
        const SizedBox(height: 12),
        _buildWorkItem(
          context,
          icon: LucideIcons.fileText,
          iconColor: Colors.purple,
          iconBgColor: Colors.purple.shade50,
          title: t.recentDocuments,
          time: t.todayAt(time: '3:00 PM'),
        ),
        const SizedBox(height: 12),
        _buildWorkItem(
          context,
          icon: LucideIcons.messageSquare,
          iconColor: Colors.purple.shade700,
          iconBgColor: Colors.purple.shade50,
          title: t.navigation.class_,
          time: t.todayAt(time: '3:00 PM'),
        ),
        const SizedBox(height: 12),
        _buildWorkItem(
          context,
          icon: LucideIcons.calendar,
          iconColor: Colors.orange,
          iconBgColor: Colors.orange.shade50,
          title: t.classes.drawer.exams,
          time: t.todayAt(time: '3:00 PM'),
        ),
      ],
    );
  }

  Widget _buildWorkItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: Themes.boxRadius,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
