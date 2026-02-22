import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/shared/helper/date_format_helper.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';

/// Minimal Metadata Footer - Displays technical details at the bottom
class QuestionMetadataSection extends ConsumerWidget {
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? ownerId;
  final String? chapter;

  const QuestionMetadataSection({
    super.key,
    this.createdAt,
    this.updatedAt,
    this.ownerId,
    this.chapter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            t.questionBank.detail.otherInfo,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          DefaultTextStyle(
            style: theme.textTheme.bodySmall!.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (chapter != null && chapter!.isNotEmpty)
                  Text(t.questionBank.detail.chapter(chapter: chapter!)),
                if (createdAt != null)
                  Text(
                    t.questionBank.detail.created(
                      date: DateFormatHelper.formatFullDateTime(
                        createdAt!,
                        ref: ref,
                      ),
                    ),
                  ),
                if (updatedAt != null)
                  Text(
                    t.questionBank.detail.lastUpdated(
                      date: DateFormatHelper.formatFullDateTime(
                        updatedAt!,
                        ref: ref,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
