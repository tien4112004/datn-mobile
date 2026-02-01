import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/widgets/image_input_field.dart';

/// Card widget for displaying and editing a matching question pair
class MatchingPairCard extends ConsumerWidget {
  final int index;
  final String leftText;
  final String? leftImageUrl;
  final String rightText;
  final String? rightImageUrl;
  final VoidCallback onRemove;
  final ValueChanged<String> onLeftTextChanged;
  final ValueChanged<String?> onLeftImageChanged;
  final ValueChanged<String> onRightTextChanged;
  final ValueChanged<String?> onRightImageChanged;
  final bool canRemove;

  const MatchingPairCard({
    super.key,
    required this.index,
    required this.leftText,
    this.leftImageUrl,
    required this.rightText,
    this.rightImageUrl,
    required this.onRemove,
    required this.onLeftTextChanged,
    required this.onLeftImageChanged,
    required this.onRightTextChanged,
    required this.onRightImageChanged,
    this.canRemove = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    t.questionBank.matching.pairNumber(number: index + 1),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (canRemove)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                    iconSize: 20,
                    onPressed: onRemove,
                    tooltip: t.questionBank.matching.removePair,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Left and Right columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.questionBank.matching.leftSide,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: leftText,
                        decoration: InputDecoration(
                          labelText: t.questionBank.matching.textLabel,
                          hintText: t.questionBank.matching.enterLeftText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        maxLines: 2,
                        onChanged: onLeftTextChanged,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return t.questionBank.matching.required;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      ImageInputField(
                        initialValue: leftImageUrl,
                        label: t.questionBank.matching.leftImage,
                        hint: t.questionBank.matching.imageHint,
                        isRequired: false,
                        onChanged: onLeftImageChanged,
                      ),
                    ],
                  ),
                ),

                // Connector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.swap_horiz_rounded,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                    ],
                  ),
                ),

                // Right side
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.questionBank.matching.rightSide,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: rightText,
                        decoration: InputDecoration(
                          labelText: t.questionBank.matching.textLabel,
                          hintText: t.questionBank.matching.enterRightText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        maxLines: 2,
                        onChanged: onRightTextChanged,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return t.questionBank.matching.required;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      ImageInputField(
                        initialValue: rightImageUrl,
                        label: t.questionBank.matching.rightImage,
                        hint: t.questionBank.matching.imageHint,
                        isRequired: false,
                        onChanged: onRightImageChanged,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
