import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Displays clickable topic suggestions to help users get started.
///
/// Extracted from PresentationGeneratePage to improve code organization.
class TopicSuggestions extends StatelessWidget {
  final Function(String) onSuggestionTap;
  final List<String> suggestions;

  const TopicSuggestions({
    super.key,
    required this.onSuggestionTap,
    this.suggestions = const [
      'Introduction to Machine Learning',
      'Climate Change Solutions',
      'Digital Marketing Strategies',
      'History of the Internet',
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Try these topics:',
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
