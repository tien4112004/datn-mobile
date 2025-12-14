import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Quick action buttons for image operations (Copy, Share, Download)
/// Displays as a compact horizontal row of icon buttons
class ImageQuickActions extends ConsumerWidget {
  final VoidCallback? onCopyPrompt;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;

  const ImageQuickActions({
    super.key,
    this.onCopyPrompt,
    this.onShare,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Copy Prompt Action
          _buildQuickActionButton(
            context,
            icon: Icons.content_copy_outlined,
            label: t.generate.imageResult.copyPrompt,
            onPressed: onCopyPrompt,
          ),

          // Share Action
          _buildQuickActionButton(
            context,
            icon: Icons.share_outlined,
            label: t.generate.imageResult.share,
            onPressed: onShare,
          ),

          // Download Action
          _buildQuickActionButton(
            context,
            icon: Icons.download_outlined,
            label: t.generate.imageResult.downloadImage,
            onPressed: onDownload,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isEnabled
                    ? Theme.of(context).colorScheme.primary
                    : context.secondaryTextColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isEnabled
                      ? context.isDarkMode
                            ? Colors.white
                            : Colors.grey[800]
                      : context.secondaryTextColor.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
