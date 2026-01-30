import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays clickable image prompt suggestions to help users get started.
///
/// Similar to TopicSuggestions but tailored for image generation with image-specific prompts.
class ImageSuggestions extends ConsumerWidget {
  final Function(String) onSuggestionTap;

  const ImageSuggestions({super.key, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final suggestions = [
      t.generate.imageGenerate.promptSuggestions.sunsetMountains,
      t.generate.imageGenerate.promptSuggestions.modernOffice,
      t.generate.imageGenerate.promptSuggestions.fantasyCharacter,
      t.generate.imageGenerate.promptSuggestions.productPhotography,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            t.generate.imageGenerate.tryThesePrompts,
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
