import 'package:datn_mobile/features/generate/states/controller_provider.dart';
import 'package:datn_mobile/features/generate/states/theme_provider.dart';
import 'package:datn_mobile/features/generate/ui/widgets/theme_preview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget that displays theme selection with visual preview cards fetched from API.
class ThemeSelectionSection extends ConsumerWidget {
  final VoidCallback? onInfoTap;

  const ThemeSelectionSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(presentationFormControllerProvider);
    final themesAsync = ref.watch(slideThemesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Theme',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              if (onInfoTap != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onInfoTap,
                  child: const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showThemeSelectionModal(context, ref),
                icon: const Icon(Icons.grid_view, size: 16),
                label: const Text('View All'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Display selected theme
          themesAsync.when(
            data: (themes) {
              final selectedTheme = themes.firstWhere(
                (t) => formState.themeId == t.id,
                orElse: () => themes.first,
              );

              return GestureDetector(
                onTap: () => _showThemeSelectionModal(context, ref),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: AspectRatio(
                    aspectRatio: 21 / 9,
                    child: ThemePreviewCard(
                      themeDto: selectedTheme,
                      isSelected: true,
                      title: selectedTheme.name,
                      onTap: () => _showThemeSelectionModal(context, ref),
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load themes',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeSelectionModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ThemeSelectionModal(),
    );
  }
}

class _ThemeSelectionModal extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(presentationFormControllerProvider);
    final formController = ref.read(
      presentationFormControllerProvider.notifier,
    );
    final themesAsync = ref.watch(slideThemesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Select Theme',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Theme grid
              Expanded(
                child: themesAsync.when(
                  data: (themes) {
                    return GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 16 / 9,
                          ),
                      itemCount: themes.length,
                      itemBuilder: (context, index) {
                        final themeDto = themes[index];
                        final isSelected = formState.themeId == themeDto.id;

                        return GestureDetector(
                          onTap: () {
                            formController.updateThemeId(themeDto.id);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : isDark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ThemePreviewCard(
                                  themeDto: themeDto,
                                  isSelected: false,
                                  title: themeDto.name,
                                  onTap: () {
                                    formController.updateThemeId(themeDto.id);
                                    Navigator.of(context).pop();
                                  },
                                ),

                                // Selected checkmark
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      'Failed to load themes: $error',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
