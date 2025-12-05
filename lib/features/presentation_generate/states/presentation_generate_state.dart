/// State class representing the presentation generation form state.
class PresentationGenerateState {
  final String? outlineResponse;
  final String? presentationResponse;
  final bool isOutlineGenerating;
  final bool isPresentationGenerating;
  final Object? error;

  const PresentationGenerateState({
    this.outlineResponse,
    this.presentationResponse,
    this.isOutlineGenerating = false,
    this.isPresentationGenerating = false,
    this.error,
  });

  factory PresentationGenerateState.initial() =>
      const PresentationGenerateState();

  factory PresentationGenerateState.outlineLoading() =>
      const PresentationGenerateState(isOutlineGenerating: true);

  factory PresentationGenerateState.presentationLoading() =>
      const PresentationGenerateState(isPresentationGenerating: true);

  factory PresentationGenerateState.outlineSuccess(String outlineResponse) =>
      PresentationGenerateState(outlineResponse: outlineResponse);

  factory PresentationGenerateState.presentationSuccess(
    String presentationResponse,
  ) => PresentationGenerateState(presentationResponse: presentationResponse);

  factory PresentationGenerateState.failure(Object error) =>
      PresentationGenerateState(error: error);

  bool get hasOutline => outlineResponse != null;
  bool get hasPresentation => presentationResponse != null;
  bool get isLoading => isOutlineGenerating || isPresentationGenerating;
  bool get hasError => error != null;

  PresentationGenerateState copyWith({
    String? outlineResponse,
    String? presentationResponse,
    bool? isOutlineGenerating,
    bool? isPresentationGenerating,
    Object? error,
  }) {
    return PresentationGenerateState(
      outlineResponse: outlineResponse ?? this.outlineResponse,
      presentationResponse: presentationResponse ?? this.presentationResponse,
      isOutlineGenerating: isOutlineGenerating ?? this.isOutlineGenerating,
      isPresentationGenerating:
          isPresentationGenerating ?? this.isPresentationGenerating,
      error: error ?? this.error,
    );
  }
}
