import 'package:datn_mobile/features/generate/domain/entity/outline_slide.dart';

/// Utility class for parsing markdown outline to slides and vice versa.
class OutlineParser {
  /// Parse markdown outline string into list of OutlineSlide objects.
  /// Supports format with ### headers and --- separators.
  static List<OutlineSlide> parseMarkdownToSlides(String markdown) {
    final lines = markdown.split('\n');
    final slides = <OutlineSlide>[];
    int order = 1;

    String? currentTitle;
    final currentContent = <String>[];

    for (final line in lines) {
      final trimmedLine = line.trim();

      // Skip separator lines
      if (trimmedLine == '---') {
        continue;
      }

      // Check if line is a slide title (starts with ###)
      if (trimmedLine.startsWith('### ')) {
        // Save previous slide if exists
        if (currentTitle != null) {
          slides.add(
            OutlineSlide(
              order: order++,
              title: currentTitle,
              content: currentContent.join('\n').trim(),
            ),
          );
        }

        // Start new slide
        currentTitle = trimmedLine.substring(4).trim();
        currentContent.clear();
      } else if (currentTitle != null && trimmedLine.isNotEmpty) {
        // Add content to current slide (preserve bullet points)
        currentContent.add(trimmedLine);
      }
    }

    // Add the last slide
    if (currentTitle != null) {
      slides.add(
        OutlineSlide(
          order: order,
          title: currentTitle,
          content: currentContent.join('\n').trim(),
        ),
      );
    }

    return slides;
  }

  /// Convert list of OutlineSlide objects back to markdown string.
  /// Uses ### headers and --- separators format.
  static String slidesToMarkdown(List<OutlineSlide> slides) {
    final buffer = StringBuffer();

    for (int i = 0; i < slides.length; i++) {
      final slide = slides[i];
      buffer.writeln('### ${slide.title}');
      if (slide.content.isNotEmpty) {
        buffer.writeln(slide.content);
      }

      // Add separator between slides (except after the last one)
      if (i < slides.length - 1) {
        buffer.writeln();
        buffer.writeln('---');
        buffer.writeln();
      }
    }

    return buffer.toString().trim();
  }

  /// Extract slide titles for preview display.
  static List<String> extractSlideTitles(String markdown) {
    final blocks = markdown.split('\n\n');

    final titles = <String>[];

    for (final firstLine in blocks) {
      final trimmedLine = firstLine.trim();
      if (trimmedLine.startsWith('### ')) {
        titles.add(trimmedLine.substring(4).trim());
      }
    }

    return titles;
  }
}
