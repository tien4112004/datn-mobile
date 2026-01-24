import 'package:flutter/material.dart';
import 'package:datn_mobile/shared/widgets/image_input_field.dart';

class QuestionTitleInput extends StatelessWidget {
  final String title;
  final ValueChanged<String> onTitleChanged;
  final String? titleImageUrl;
  final ValueChanged<String?> onTitleImageChanged;

  const QuestionTitleInput({
    super.key,
    required this.title,
    required this.onTitleChanged,
    this.titleImageUrl,
    required this.onTitleImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            TextFormField(
              initialValue: title,
              onChanged: onTitleChanged,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your question...',
                hintStyle: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(
                  right: 48,
                ), // Space for image button
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Question title is required';
                }
                return null;
              },
            ),
            // Image button embedded
            _buildImageButton(context),
          ],
        ),

        // Show selected image if any
        if (titleImageUrl != null) ...[
          const SizedBox(height: 12),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  titleImageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.error.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: colorScheme.error,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => onTitleImageChanged(null),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer,
                    foregroundColor: colorScheme.onErrorContainer,
                  ),
                  tooltip: 'Remove image',
                ),
              ),
            ],
          ),
        ],
        const Divider(),
      ],
    );
  }

  Widget _buildImageButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return IconButton(
      icon: Icon(
        Icons.image_outlined,
        color: titleImageUrl != null
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant,
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => Padding(
            padding: const EdgeInsets.only(
              top: 16,
              bottom: 32,
              left: 16,
              right: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select Question Image",
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ImageInputField(
                  initialValue: titleImageUrl,
                  onChanged: (val) {
                    onTitleImageChanged(val);
                    Navigator.pop(context);
                  },
                  label: "Question Image",
                ),
              ],
            ),
          ),
        );
      },
      tooltip: 'Add Image',
    );
  }
}
