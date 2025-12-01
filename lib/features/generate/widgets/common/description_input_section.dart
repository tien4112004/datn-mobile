import 'package:datn_mobile/shared/widget/prompt_input_with_suggestions.dart';
import 'package:flutter/material.dart';

/// Widget for inputting the main description/prompt for content generation
/// Includes suggestion chips for quick input
class DescriptionInputSection extends StatelessWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final String label;
  final String hint;

  const DescriptionInputSection({
    super.key,
    required this.controller,
    this.suggestions = const [],
    this.label = 'Describe your content',
    this.hint = 'Enter your description...',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 10),
        PromptInputWithSuggestions(
          controller: controller,
          hint: hint,
          suggestions: suggestions,
        ),
      ],
    );
  }
}
