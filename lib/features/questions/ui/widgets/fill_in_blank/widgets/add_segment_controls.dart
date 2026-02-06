import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Add segment controls for fill in blank editing
class AddSegmentControls extends ConsumerWidget {
  final VoidCallback onAddText;
  final VoidCallback onAddBlank;

  const AddSegmentControls({
    super.key,
    required this.onAddText,
    required this.onAddBlank,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onAddText,
            icon: const Icon(Icons.text_fields),
            label: Text(t.questionBank.fillInBlank.addText),
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
            label: Text(t.questionBank.fillInBlank.addBlank),
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
