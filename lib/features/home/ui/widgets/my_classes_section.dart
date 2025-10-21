import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/i18n/strings.g.dart';

class MyClassesSection extends ConsumerWidget {
  const MyClassesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.myClasses,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 16),
        _buildClassCard(
          context,
          t: t,
          className: 'Grade 4 - Reading',
          classCode: 'ENG4-01',
          dueDate: '29/12/2024',
          color: Colors.blue.shade50,
        ),
        const SizedBox(height: 16),
        _buildClassCard(
          context,
          t: t,
          className: 'Grade 4 - Mathematics',
          classCode: 'MATH4-01',
          dueDate: '06/01/2025',
          color: Colors.purple.shade50,
        ),
        const SizedBox(height: 16),
        _buildClassCard(
          context,
          t: t,
          className: 'Grade 4 - Science',
          classCode: 'SCI4-01',
          dueDate: '30/12/2024',
          color: Colors.green.shade50,
        ),
      ],
    );
  }

  Widget _buildClassCard(
    BuildContext context, {
    required Translations t,
    required String className,
    required String classCode,
    required String dueDate,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color, borderRadius: Themes.boxRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            className,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            classCode,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            t.dueDate.replaceAll('{date}', dueDate),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
