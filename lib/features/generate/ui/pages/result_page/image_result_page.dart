import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/result_page/image_display_card.dart';
import 'package:datn_mobile/features/generate/ui/widgets/result_page/image_metadata_card.dart';
import 'package:datn_mobile/features/generate/ui/widgets/result_page/image_quick_actions.dart';
import 'package:datn_mobile/i18n/strings.g.dart';
import 'package:datn_mobile/shared/pods/translation_pod.dart';
import 'package:datn_mobile/shared/services/download/download_service_pod.dart';
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
      backgroundColor: context.isDarkMode
          ? cs.surface
          : const Color(0xFFF9FAFB),
      body: generateState.when(
        data: (state) {
          final image = state.generatedImage;
          if (image == null) {
            return _buildNoImageState(context, t);
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
                  onShare: () => _shareImage(context, ref, image.url, t),
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
        loading: () {
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
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.badgeAlert, size: 64, color: cs.error),
                  const SizedBox(height: 16),
                  Text(
                    t.generate.imageResult.errorGeneratingImage,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.isDarkMode
                          ? Colors.white
                          : Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.router.back(),
                    child: Text(t.generate.imageResult.generateAnother),
                  ),
                ],
              ),
            ),
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

  Widget _buildNoImageState(BuildContext context, Translations t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.imageOff,
            size: 64,
            color: context.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            t.generate.imageResult.noImageGenerated,
            style: TextStyle(fontSize: 16, color: context.secondaryTextColor),
          ),
        ],
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

  void _shareImage(
    BuildContext context,
    WidgetRef ref,
    String? url,
    Translations t,
  ) {
    if (url == null || url.isEmpty) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.generate.imageResult.share)));
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
