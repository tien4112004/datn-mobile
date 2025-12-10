part of '../controller_provider.dart';

/// Controller for managing outline editing operations.
///
/// State is explicitly kept alive to preserve slide edits during navigation.
class OutlineEditingController extends Notifier<OutlineEditingState> {
  @override
  OutlineEditingState build() {
    // Keep state alive to prevent loss of edits during navigation
    ref.keepAlive();
    return const OutlineEditingState();
  }

  /// Initialize the outline editing state from markdown outline.
  void initializeFromOutline(String markdownOutline) {
    final parser = ref.read(outlineParserRepositoryProvider);
    final slides = parser.parseMarkdownToSlides(markdownOutline);
    state = state.copyWith(slides: slides);
  }

  /// Update the content of a specific slide.
  void updateSlideContent(int slideOrder, String title, String content) {
    final updatedSlides = state.slides.map((slide) {
      if (slide.order == slideOrder) {
        return slide.copyWith(title: title, content: content);
      }
      return slide;
    }).toList();

    state = state.copyWith(slides: updatedSlides);
  }

  /// Add a new slide at the specified position.
  void addSlide(int afterOrder) {
    final newOrder = afterOrder + 1;
    final newSlide = OutlineSlide(
      order: newOrder,
      title: 'New Slide',
      content: 'Add your slide content here...',
    );

    // Shift orders of subsequent slides
    final updatedSlides = <OutlineSlide>[];
    for (final slide in state.slides) {
      if (slide.order > afterOrder) {
        updatedSlides.add(slide.copyWith(order: slide.order + 1));
      } else {
        updatedSlides.add(slide);
      }
    }

    // Insert new slide
    updatedSlides.add(newSlide);
    updatedSlides.sort((a, b) => a.order.compareTo(b.order));

    state = state.copyWith(slides: updatedSlides);
  }

  /// Remove a slide by its order.
  void removeSlide(int slideOrder) {
    final updatedSlides = state.slides
        .where((slide) => slide.order != slideOrder)
        .map((slide) {
          // Shift orders of subsequent slides
          if (slide.order > slideOrder) {
            return slide.copyWith(order: slide.order - 1);
          }
          return slide;
        })
        .toList();

    state = state.copyWith(slides: updatedSlides);
  }

  /// Reorder slides by swapping positions.
  void reorderSlides(int fromOrder, int toOrder) {
    if (fromOrder == toOrder) return;

    final slides = List<OutlineSlide>.from(state.slides);
    final fromIndex = slides.indexWhere((slide) => slide.order == fromOrder);
    final toIndex = slides.indexWhere((slide) => slide.order == toOrder);

    if (fromIndex == -1 || toIndex == -1) return;

    // Swap the slides
    final temp = slides[fromIndex];
    slides[fromIndex] = slides[toIndex].copyWith(order: fromOrder);
    slides[toIndex] = temp.copyWith(order: toOrder);

    state = state.copyWith(slides: slides);
  }

  /// Convert the current slides back to markdown outline.
  String getMarkdownOutline() {
    final parser = ref.read(outlineParserRepositoryProvider);
    return parser.slidesToMarkdown(state.slides);
  }

  /// Reset the editing state.
  void reset() {
    state = const OutlineEditingState();
  }
}
