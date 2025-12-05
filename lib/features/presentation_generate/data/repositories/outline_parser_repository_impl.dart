import 'package:datn_mobile/features/presentation_generate/domain/entity/outline_slide.dart';
import 'package:datn_mobile/features/presentation_generate/domain/repositories/outline_parser_repository.dart';
import 'package:datn_mobile/features/presentation_generate/service/outline_parser.dart';

/// Implementation of OutlineParserRepository that delegates to OutlineParser.
///
/// This wraps the static OutlineParser utility class to make it injectable
/// and testable through the repository pattern.
class OutlineParserRepositoryImpl implements OutlineParserRepository {
  const OutlineParserRepositoryImpl();

  @override
  List<OutlineSlide> parseMarkdownToSlides(String markdown) {
    return OutlineParser.parseMarkdownToSlides(markdown);
  }

  @override
  String slidesToMarkdown(List<OutlineSlide> slides) {
    return OutlineParser.slidesToMarkdown(slides);
  }

  @override
  List<String> extractSlideTitles(String markdown) {
    return OutlineParser.extractSlideTitles(markdown);
  }
}
