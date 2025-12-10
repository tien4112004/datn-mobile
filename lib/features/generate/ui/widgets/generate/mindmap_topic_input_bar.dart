import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom input bar for entering mindmap topics with generate action.
///
/// Customized for mindmap generation with topic input and generate button.
/// Handles topic input and generation with proper loading states.
class MindmapTopicInputBar extends ConsumerWidget {
  final TextEditingController topicController;
  final FocusNode topicFocusNode;
  final VoidCallback onGenerate;

  const MindmapTopicInputBar({
    super.key,
    required this.topicController,
    required this.topicFocusNode,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(mindmapFormControllerProvider);
    final generateState = ref.watch(mindmapGenerateControllerProvider);

    final isLoading = generateState.isLoading;
    final isValid = formState.isValid;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: ThemeDecorations.containerWithTopBorder(context),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: topicController,
              focusNode: topicFocusNode,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Enter your mindmap topic',
                hintStyle: TextStyle(color: context.secondaryTextColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: context.isDarkMode
                    ? Colors.grey[800]
                    : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                counterText: '',
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Generate Button
          Material(
            color: isValid
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: isValid && !isLoading ? onGenerate : null,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
