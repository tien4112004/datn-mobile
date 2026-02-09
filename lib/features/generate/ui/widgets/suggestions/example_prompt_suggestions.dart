import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/features/generate/states/example_prompt/example_prompt_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays clickable prompt suggestions fetched from the backend API.
///
/// Replaces the hardcoded ImageSuggestions, TopicSuggestions, and
/// MindmapSuggestions widgets with a single dynamic widget.
class ExamplePromptSuggestions extends ConsumerWidget {
  final String type;
  final String headerText;
  final Function(String) onSuggestionTap;

  const ExamplePromptSuggestions({
    super.key,
    required this.type,
    required this.headerText,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPrompts = ref.watch(examplePromptsProvider(type));

    return asyncPrompts.when(
      data: (prompts) {
        if (prompts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                headerText,
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
              children: prompts.map((prompt) {
                return InkWell(
                  onTap: () => onSuggestionTap(prompt.prompt),
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
                      prompt.prompt,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.bodyTextColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => _buildSkeleton(context),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final shimmerColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.08);
    final widths = [90.0, 120.0, 70.0, 110.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: 100,
            height: 12,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widths
              .map(
                (w) => Container(
                  width: w,
                  height: 32,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
