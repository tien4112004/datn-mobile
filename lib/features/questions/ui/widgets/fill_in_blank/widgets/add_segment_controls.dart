import 'package:flutter/material.dart';

/// Add segment controls for fill in blank editing
class AddSegmentControls extends StatelessWidget {
  final VoidCallback onAddText;
  final VoidCallback onAddBlank;

  const AddSegmentControls({
    super.key,
    required this.onAddText,
    required this.onAddBlank,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onAddText,
            icon: const Icon(Icons.text_fields),
            label: const Text('Add Text'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.secondary,
              side: BorderSide(color: colorScheme.secondary),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onAddBlank,
            icon: const Icon(Icons.space_bar),
            label: const Text('Add Blank'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}
