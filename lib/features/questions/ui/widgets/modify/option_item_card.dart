import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:AIPrimary/shared/widgets/image_input_field.dart';

/// Row widget for displaying and editing a multiple choice option
class OptionItemCard extends ConsumerWidget {
  final int index;
  final String text;
  final String? imageUrl;
  final bool isCorrect;
  final VoidCallback onRemove;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String?> onImageUrlChanged;
  final ValueChanged<bool> onCorrectChanged;
  final bool canRemove;
  final bool
  isMultipleSelect; // To decide between Radio style or Checkbox style

  const OptionItemCard({
    super.key,
    required this.index,
    required this.text,
    this.imageUrl,
    required this.isCorrect,
    required this.onRemove,
    required this.onTextChanged,
    required this.onImageUrlChanged,
    required this.onCorrectChanged,
    this.canRemove = true,
    this.isMultipleSelect = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final t = ref.watch(translationsPod);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Align to top if multi-line text
        children: [
          InkWell(
            onTap: () => onCorrectChanged(!isCorrect),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                isMultipleSelect
                    ? (isCorrect
                          ? Icons.check_box
                          : Icons.check_box_outline_blank)
                    : (isCorrect
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked),
                color: isCorrect
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: text,
                  decoration: InputDecoration(
                    hintText: t.questionBank.multipleChoice.optionHint(
                      number: index + 1,
                    ),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  style: theme.textTheme.bodyMedium,
                  minLines: 1,
                  maxLines: 3,
                  onChanged: onTextChanged,
                ),
                if (imageUrl != null) ...[
                  const SizedBox(height: 4),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(
                                width: 100,
                                height: 100,
                                child: Icon(Icons.broken_image),
                              ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => onImageUrlChanged(null),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imageUrl == null)
                IconButton(
                  icon: Icon(
                    Icons.image_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    // Simple image picker dialog for option
                    _showImagePickerDialog(context, ref);
                  },
                  tooltip: t.questionBank.multipleChoice.addImageTooltip,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                  iconSize: 20,
                ),
              if (canRemove)
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                  onPressed: onRemove,
                  tooltip: t.questionBank.multipleChoice.removeTooltip,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                  iconSize: 20,
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImagePickerDialog(BuildContext context, WidgetRef ref) {
    final t = ref.read(translationsPod);
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.questionBank.multipleChoice.optionImage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ImageInputField(
              initialValue: imageUrl,
              onChanged: (val) {
                onImageUrlChanged(val);
                Navigator.pop(context);
              },
              label: t.questionBank.multipleChoice.optionImageLabel(
                number: index + 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
