import 'package:datn_mobile/features/generate/domain/entity/outline_slide.dart';

/// State class for managing outline editing operations.
class OutlineEditingState {
  final List<OutlineSlide> slides;
  final bool isLoading;
  final String? error;

  const OutlineEditingState({
    this.slides = const [],
    this.isLoading = false,
    this.error,
  });

  OutlineEditingState copyWith({
    List<OutlineSlide>? slides,
    bool? isLoading,
    String? error,
  }) {
    return OutlineEditingState(
      slides: slides ?? this.slides,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasSlides => slides.isNotEmpty;
  int get slideCount => slides.length;

  @override
  String toString() {
    return 'OutlineEditingState(slides: ${slides.length}, isLoading: $isLoading, error: $error)';
  }
}
