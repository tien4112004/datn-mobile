import 'package:datn_mobile/features/generate/domain/entity/outline_slide.dart';

/// Repository interface for outline parsing operations.
///
/// This abstraction decouples the UI from the service layer implementation,
/// making the code more testable and maintainable.
abstract class OutlineParserRepository {
  /// Parse a markdown outline string into a list of OutlineSlide objects.
  ///
  /// Expected markdown format:
  /// ```
  /// ### Slide Title
  /// Slide content here
  /// ---
  /// ### Another Slide
  /// More content
  /// ---
  /// ```
  List<OutlineSlide> parseMarkdownToSlides(String markdown);

  /// Convert a list of OutlineSlide objects back to markdown format.
  String slidesToMarkdown(List<OutlineSlide> slides);

  /// Extract just the slide titles from a markdown outline.
  ///
  /// This is useful for displaying a preview or summary of the outline.
  List<String> extractSlideTitles(String markdown);
}
