import 'package:flutter/material.dart';
import 'package:AIPrimary/shared/widgets/input_card.dart';
import 'package:AIPrimary/shared/widgets/sample_prompt.dart';

class PromptInputWithSuggestions extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final List<String> suggestions;

  const PromptInputWithSuggestions({
    super.key,
    required this.controller,
    required this.hint,
    required this.suggestions,
  });

  @override
  State<PromptInputWithSuggestions> createState() =>
      _PromptInputWithSuggestionsState();
}

class _PromptInputWithSuggestionsState
    extends State<PromptInputWithSuggestions> {
  final Set<String> selected = {};

  @override
  void initState() {
    super.initState();
    // Listen to text changes to show/hide pills
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputCard(controller: widget.controller, hint: widget.hint),
        const SizedBox(height: 12),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: widget.controller.text.isEmpty
              ? Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.suggestions
                      .map(
                        (suggestion) => SamplePrompt(
                          text: suggestion,
                          selected: selected.contains(suggestion),
                          visible: widget.controller.text.isEmpty,
                          onTap: () {
                            setState(() {
                              // Add the text to the description
                              widget.controller.text = suggestion;
                            });
                          },
                        ),
                      )
                      .toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
