import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom input bar for entering presentation topics with attach and generate actions.
///
/// Extracted from PresentationGeneratePage to improve code organization.
/// Handles topic input, file attachment, and generation with proper loading states.
class TopicInputBar extends ConsumerWidget {
  final TextEditingController topicController;
  final FocusNode topicFocusNode;
  final VoidCallback onAttachFile;
  final VoidCallback onGenerate;
  final NotifierProvider formState;
  final AsyncNotifierProvider generateState;
  final String hintText;

  const TopicInputBar({
    super.key,
    required this.topicController,
    required this.topicFocusNode,
    required this.onAttachFile,
    required this.onGenerate,
    required this.formState,
    required this.generateState,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(this.formState);
    final generateStateAsync = ref.watch(generateState);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildAttachButton(context),
            const SizedBox(width: 8),
            _buildTextInput(context),
            const SizedBox(width: 8),
            _buildGenerateButton(
              context,
              formState.isValid,
              generateStateAsync,
            ),
          ],
        ),
      ),
    );
  }

  /// Attach file button.
  Widget _buildAttachButton(BuildContext context) {
    return Material(
      color: context.isDarkMode ? Colors.grey[800] : Colors.grey[100],
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onAttachFile,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            Icons.attach_file_rounded,
            color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  /// Expandable text input field.
  Widget _buildTextInput(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 120),
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? Colors.grey[800]
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextField(
          controller: topicController,
          focusNode: topicFocusNode,
          maxLines: null,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: context.isDarkMode ? Colors.grey[500] : Colors.grey[400],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            color: context.isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
      ),
    );
  }

  /// Generate button with loading state using easyWhen.
  Widget _buildGenerateButton(
    BuildContext context,
    bool isValid,
    AsyncValue generateStateAsync,
  ) {
    final isLoading = generateStateAsync.isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isValid && !isLoading
            ? Theme.of(context).colorScheme.primary
            : (context.isDarkMode ? Colors.grey[700] : Colors.grey[300]),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: isValid && !isLoading ? onGenerate : null,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: generateStateAsync.easyWhen(
              data: (_) => Icon(
                Icons.arrow_upward_rounded,
                color: isValid ? Colors.white : Colors.grey[500],
              ),
              loadingWidget: () => const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              skipLoadingOnRefresh: false,
            ),
          ),
        ),
      ),
    );
  }
}
