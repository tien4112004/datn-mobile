import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/result_page/image_display_card.dart';
import 'package:datn_mobile/features/generate/ui/widgets/result_page/image_metadata_card.dart';
import 'package:datn_mobile/features/generate/ui/widgets/result_page/image_quick_actions.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/riverpod_ext/async_value_easy_when.dart';
import 'package:datn_mobile/shared/services/service_pod.dart';
import 'package:datn_mobile/shared/widget/enhanced_empty_state.dart';
import 'package:datn_mobile/shared/widget/enhanced_error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@RoutePage()
class ImageResultPage extends ConsumerWidget {
  const ImageResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsPod);
    final generateState = ref.watch(imageGenerateControllerProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: _buildAppBar(context, t),
      backgroundColor: cs.surface,
      body: generateState.easyWhen(
        data: (state) {
          final image = state.generatedImage;
          if (image == null) {
            return EnhancedEmptyState(
              icon: LucideIcons.imageOff,
              title: t.generate.imageResult.noImageGenerated,
              message: 'Please try generating an image first',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Generated Image Display (with more space)
                ImageDisplayCard(imageUrl: image.url),
                const SizedBox(height: 28),

                // Metadata Card (reorganized: Prompt, Model, Aspect Ratio)
                ImageMetadataCard(generatedImage: image),
                const SizedBox(height: 24),

                // Quick Actions (compact icon row)
                ImageQuickActions(
                  onCopyPrompt: () =>
                      _copyPromptToClipboard(context, ref, image.prompt, t),
                  onShare: () =>
                      _shareImage(context, ref, image.url, t, image.prompt),
                  onDownload: () =>
                      _downloadImage(context, ref, image.url, image.prompt, t),
                ),
                const SizedBox(height: 20),

                // Primary Action Button (full width)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.router.back(),
                    icon: const Icon(LucideIcons.rotateCw),
                    label: Text(t.generate.imageResult.generateAnother),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loadingWidget: () {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(cs.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  t.generate.imageResult.generatingImage,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          );
        },
        errorWidget: (error, stackTrace) {
          return EnhancedErrorState(
            icon: LucideIcons.badgeAlert,
            title: t.generate.imageResult.errorGeneratingImage,
            message: error.toString(),
            actionLabel: t.generate.imageResult.generateAnother,
            onRetry: () => context.router.back(),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Translations t) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      title: Row(
        children: [
          Icon(LucideIcons.images, size: 24, color: cs.primary),
          const SizedBox(width: 8),
          Text(t.generate.imageResult.title),
        ],
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: context.isDarkMode ? cs.surface : Colors.white,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft),
        onPressed: () => context.router.back(),
      ),
    );
  }

  void _copyPromptToClipboard(
    BuildContext context,
    WidgetRef ref,
    String? prompt,
    Translations t,
  ) {
    if (prompt == null || prompt.isEmpty) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.generate.imageResult.copyPrompt)));
  }

  Future<void> _shareImage(
    BuildContext context,
    WidgetRef ref,
    String? url,
    Translations t,
    String? prompt,
  ) async {
    if (url == null || url.isEmpty) return;

    final shareService = ref.read(shareServiceProvider);

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                t.generate.imageResult.downloadImage,
              ), // Reusing download message "Downloading..."
            ],
          ),
          duration: const Duration(
            seconds: 1,
          ), // Short duration or hide manually
        ),
      );

      await shareService.shareImage(url: url, prompt: prompt);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share image: $e')));
      }
    }
  }

  void _downloadImage(
    BuildContext context,
    WidgetRef ref,
    String url,
    String? prompt,
    Translations t,
  ) {
    final downloadService = ref.read(downloadServiceProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.generate.imageResult.downloadImage)),
    );

    downloadService
        .downloadImageToGallery(url: url, prompt: prompt ?? 'image')
        .listen(
          (progress) {
            // Optional: Handle progress updates
          },
          onDone: () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.generate.imageResult.imageSavedToGallery),
                ),
              );
            }
          },
          onError: (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${t.generate.imageResult.failedToSaveImage} $error',
                  ),
                ),
              );
            }
          },
        );
  }
}
