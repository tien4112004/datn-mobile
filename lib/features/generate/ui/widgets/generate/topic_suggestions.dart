import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays clickable topic suggestions to help users get started.
///
/// Extracted from PresentationGeneratePage to improve code organization.
class TopicSuggestions extends ConsumerWidget {
  final Function(String) onSuggestionTap;

  const TopicSuggestions({super.key, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with dynamic suggestions from backend in the future.
    final t = ref.watch(translationsPod);
    final suggestions = [
      t.generate.presentationGenerate.topicSuggestions.climateChange,
      t.generate.presentationGenerate.topicSuggestions.digitalMarketing,
      t.generate.presentationGenerate.topicSuggestions.internetHistory,
      t.generate.presentationGenerate.topicSuggestions.machineLearning,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            t.generate.presentationGenerate.tryTheseTopics,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.tertiaryTextColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((suggestion) {
            return InkWell(
              onTap: () => onSuggestionTap(suggestion),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? Colors.grey[800]?.withValues(alpha: 0.5)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  suggestion,
                  style: TextStyle(fontSize: 12, color: context.bodyTextColor),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
