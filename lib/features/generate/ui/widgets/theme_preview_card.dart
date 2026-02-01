import 'package:AIPrimary/features/generate/data/dto/slide_theme_dto.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A visual card that previews a slide theme from API with title, body text, and color palette.
///
/// This widget displays a miniature version of how a theme will look with:
/// - A colored background
/// - Title and body text in theme-appropriate colors
/// - A color palette strip showing the theme's accent colors
/// - A selection indicator when the theme is selected
class ThemePreviewCard extends StatelessWidget {
  /// The theme DTO to display
  final SlideThemeDto themeDto;

  /// Whether this theme is currently selected
  final bool isSelected;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Title text to display on the preview
  final String title;

  /// Width of the preview (aspect ratio will be 21:9 if not constrained)
  final double? width;

  /// Height of the preview (aspect ratio will be 21:9 if not constrained)
  final double? height;

  const ThemePreviewCard({
    super.key,
    required this.themeDto,
    this.isSelected = false,
    this.onTap,
    this.title = 'Title',
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = isSelected ? colorScheme.primary : Colors.grey[300];
    final borderWidth = isSelected ? 2.0 : 2.0;

    final backgroundColorOrGradient = themeDto.getBackgroundColorOrGradient();
    final flutterColors = themeDto.getThemeColorsAsFlutterColors();
    final titleColor = themeDto.titleFontColor != null
        ? SlideThemeDto.parseColor(themeDto.titleFontColor!)
        : Colors.black;
    final fontColor = SlideThemeDto.parseColor(themeDto.fontColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor ?? Colors.grey,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
            if (isSelected)
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Background
            Container(
              decoration: BoxDecoration(
                color: backgroundColorOrGradient is Color
                    ? backgroundColorOrGradient
                    : null,
                gradient: backgroundColorOrGradient is Gradient
                    ? backgroundColorOrGradient
                    : null,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            // Content layout
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title text
                  SizedBox(
                    height: 20,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor,
                        fontFamily: themeDto.titleFontName ?? themeDto.fontName,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Body text
                  SizedBox(
                    height: 16,
                    child: Text(
                      'Body',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fontColor,
                        fontFamily: themeDto.fontName,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // Spacer to push color palette to bottom
                  const Spacer(),
                  // Color palette strip
                  SizedBox(
                    height: 8,
                    child: Row(
                      children: List.generate(
                        (flutterColors.length > 5 ? 5 : flutterColors.length),
                        (index) {
                          final color = flutterColors[index];
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
