import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PostEditorSection extends StatelessWidget {
  final quill.QuillController controller;
  final bool isLoading;
  final FocusNode? focusNode;

  const PostEditorSection({
    super.key,
    required this.controller,
    required this.isLoading,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      constraints: const BoxConstraints(
        minHeight: 300, // Minimum height
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  LucideIcons.fileText,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Content',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF), // purple-100
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.sparkles,
                        size: 12,
                        color: Color(0xFF9333EA), // purple-600
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Rich Text',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7C3AED), // purple-700
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),

          // Rich Text Editor (flexible, grows with content)
          Padding(
            padding: const EdgeInsets.all(16),
            child: quill.QuillEditor.basic(
              controller: controller,
              focusNode: focusNode,
              config: quill.QuillEditorConfig(
                padding: const EdgeInsets.all(12),
                placeholder: 'Write your post content here...',
                customStyles: quill.DefaultStyles(
                  paragraph: quill.DefaultTextBlockStyle(
                    theme.textTheme.bodyLarge!,
                    const quill.HorizontalSpacing(0, 0),
                    const quill.VerticalSpacing(8, 8),
                    const quill.VerticalSpacing(0, 0),
                    null,
                  ),
                  placeHolder: quill.DefaultTextBlockStyle(
                    theme.textTheme.bodyLarge!.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    const quill.HorizontalSpacing(0, 0),
                    const quill.VerticalSpacing(0, 0),
                    const quill.VerticalSpacing(0, 0),
                    null,
                  ),
                ),
                scrollable: true,
                autoFocus: false,
                expands: false,
                checkBoxReadOnly: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
