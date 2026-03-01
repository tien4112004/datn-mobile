import 'package:AIPrimary/core/theme/app_theme.dart';
import 'package:AIPrimary/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/coins/ui/widgets/coin_balance_indicator.dart';
import 'package:AIPrimary/core/router/router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

  /// Attached file names/urls to display as chips above the input
  final List<String> attachedFileNames;

  /// Called when the user taps the remove button on a file chip
  final void Function(String fileName)? onRemoveFile;

  const TopicInputBar({
    super.key,
    required this.topicController,
    required this.topicFocusNode,
    required this.onAttachFile,
    required this.onGenerate,
    required this.formState,
    required this.generateState,
    required this.hintText,
    this.attachedFileNames = const [],
    this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(this.formState);
    final generateStateAsync = ref.watch(generateState);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Coin balance banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: context.surfaceColor),
          alignment: Alignment.topRight,
          child: CoinBalanceIndicator(
            onTap: () {
              context.router.push(const PaymentMethodsRoute());
            },
          ),
        ),
        // Input bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceColor,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File chips row
                if (attachedFileNames.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: attachedFileNames
                        .map((name) => _buildFileChip(context, name))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                // Input row
                Row(
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Strips the UUID prefix from an uploaded filename.
  /// Format: `<uuid>-<original-name>` → returns `<original-name>`.
  String _displayName(String name) {
    // UUID pattern: 8-4-4-4-12 hex chars followed by a dash
    final uuidPrefixPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}-',
    );
    return name.replaceFirst(uuidPrefixPattern, '');
  }

  Widget _buildFileChip(BuildContext context, String name) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = _displayName(name);
    const double chipSize = 64;

    return SizedBox(
      width: chipSize,
      height: chipSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main square chip body
          Material(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {},
              child: Container(
                width: chipSize,
                height: chipSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.fileText,
                      size: 24,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 9,
                        color: colorScheme.primary,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Delete button in top-right corner
          if (onRemoveFile != null)
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: () => onRemoveFile!(name),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    size: 11,
                    color: colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
        ],
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
