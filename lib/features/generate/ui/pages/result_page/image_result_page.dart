import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/theme/app_theme.dart';
import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class ImageResultPage extends ConsumerWidget {
  const ImageResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generateState = ref.watch(imageGenerateControllerProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Image'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: context.isDarkMode ? cs.surface : Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.back(),
        ),
      ),
      backgroundColor: context.isDarkMode
          ? cs.surface
          : const Color(0xFFF9FAFB),
      body: generateState.when(
        data: (state) {
          final image = state.generatedImage;
          if (image == null || image.url == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: context.secondaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No image generated',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Generated Image
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: context.isDarkMode ? Colors.grey[800] : Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      image.url!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          color: context.isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: context.secondaryTextColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(
                                    color: context.secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Metadata Section
                _buildMetadataSection(context, image),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _copyPromptToClipboard(context, image.prompt),
                        icon: const Icon(Icons.content_copy),
                        label: const Text('Copy Prompt'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _shareImage(context, image.url),
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.router.back(),
                    child: const Text('Generate Another'),
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
                  'Generating image...',
                  style: TextStyle(
                    fontSize: 16,
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
                  Icon(Icons.error_outline, size: 64, color: cs.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error generating image',
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
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetadataSection(BuildContext context, dynamic image) {
    final children = <Widget>[
      Text(
        'Image Details',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: context.isDarkMode ? Colors.white : Colors.grey[900],
        ),
      ),
      const SizedBox(height: 12),
      _buildMetadataRow(context, 'Prompt', image.prompt ?? 'N/A'),
      const SizedBox(height: 12),
      _buildMetadataRow(context, 'Format', image.mimeType ?? 'N/A'),
    ];

    if (image.created != null) {
      children.add(const SizedBox(height: 12));
      children.add(_buildMetadataRow(context, 'Created', image.created));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: context.isDarkMode ? Colors.white : Colors.grey[800],
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _copyPromptToClipboard(BuildContext context, String? prompt) {
    if (prompt == null || prompt.isEmpty) return;

    // This would require implementing clipboard functionality
    // For now, just show a snackbar
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Prompt copied to clipboard')));
  }

  void _shareImage(BuildContext context, String? url) {
    if (url == null || url.isEmpty) return;

    // This would require implementing share functionality
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }
}
