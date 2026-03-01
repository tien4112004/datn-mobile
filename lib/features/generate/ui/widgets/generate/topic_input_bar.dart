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
  final VoidCallback? onAttachFile;
  final VoidCallback onGenerate;
  final NotifierProvider formState;
  final AsyncNotifierProvider generateState;
  final String hintText;

  /// Full CDN URLs of attached files to display as chips above the input.
  final List<String> attachedFileUrls;

  /// Called with the full CDN URL when the user taps the remove button.
  final void Function(String url)? onRemoveFile;

  const TopicInputBar({
    super.key,
    required this.topicController,
    required this.topicFocusNode,
    this.onAttachFile,
    required this.onGenerate,
    required this.formState,
    required this.generateState,
    required this.hintText,
    this.attachedFileUrls = const [],
    this.onRemoveFile,
  });

  static const _imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'};

  bool _isImageUrl(String url) {
    final ext = url.split('.').last.split('?').first.toLowerCase();
    return _imageExtensions.contains(ext);
  }

  /// Strips the UUID prefix from an uploaded filename.
  /// Format: `<uuid>-<original-name>` → returns `<original-name>`.
  String _displayName(String url) {
    final filename = Uri.parse(url).pathSegments.lastOrNull ?? url;
    final uuidPrefixPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}-',
    );
    return filename.replaceFirst(uuidPrefixPattern, '');
  }

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
                if (attachedFileUrls.isNotEmpty) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < attachedFileUrls.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          _buildFileChip(context, attachedFileUrls[i]),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                // Input row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    onAttachFile != null
                        ? _buildAttachButton(context)
                        : const SizedBox.shrink(),
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

  Widget _buildFileChip(BuildContext context, String url) {
    return _isImageUrl(url)
        ? _buildImageChip(context, url)
        : _buildDocumentChip(context, url);
  }

  Widget _buildImageChip(BuildContext context, String url) {
    final colorScheme = Theme.of(context).colorScheme;
    const double chipSize = 64;

    return SizedBox(
      width: chipSize,
      height: chipSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              url,
              width: chipSize,
              height: chipSize,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: chipSize,
                height: chipSize,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  LucideIcons.imageOff,
                  size: 24,
                  color: colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          // Delete button
          _buildDeleteButton(context, url),
        ],
      ),
    );
  }

  Widget _buildDocumentChip(BuildContext context, String url) {
    final name = _displayName(url);
    final ext = url.split('.').last.split('?').first.toLowerCase();
    final chipColor = _docColor(ext);
    const double chipSize = 64;

    return SizedBox(
      width: chipSize,
      height: chipSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: chipColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: chipSize,
              height: chipSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: chipColor.withValues(alpha: 0.25)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_docIcon(ext), size: 22, color: chipColor),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 9,
                      color: chipColor,
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
          _buildDeleteButton(context, url),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, String url) {
    if (onRemoveFile == null) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      top: -6,
      right: -6,
      child: GestureDetector(
        onTap: () => onRemoveFile!(url),
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Icon(
            Icons.close,
            size: 11,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Color _docColor(String ext) {
    return switch (ext) {
      'pdf' => const Color(0xFFE53935),
      'doc' || 'docx' => const Color(0xFF1565C0),
      'txt' => const Color(0xFF546E7A),
      _ => const Color(0xFF546E7A),
    };
  }

  IconData _docIcon(String ext) {
    return switch (ext) {
      'pdf' => LucideIcons.fileType,
      'doc' || 'docx' => LucideIcons.fileText,
      'txt' => LucideIcons.fileCode,
      _ => LucideIcons.file,
    };
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
