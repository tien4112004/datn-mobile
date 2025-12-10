/// State class representing the presentation generation form state.
///
/// Uses request IDs to track completion and avoid race conditions when
/// listening to state changes in the UI.
class PresentationGenerateState {
  final String? outlineResponse;
  final String? presentationResponse;
  final bool isOutlineGenerating;
  final bool isPresentationGenerating;
  final Object? error;

  /// Current request ID (updated when a new request starts)
  final String? currentRequestId;

  /// Last processed outline request ID (used to detect new outline completions)
  final String? lastProcessedOutlineRequestId;

  /// Last processed presentation request ID (used to detect new presentation completions)
  final String? lastProcessedPresentationRequestId;

  const PresentationGenerateState({
    this.outlineResponse,
    this.presentationResponse,
    this.isOutlineGenerating = false,
    this.isPresentationGenerating = false,
    this.error,
    this.currentRequestId,
    this.lastProcessedOutlineRequestId,
    this.lastProcessedPresentationRequestId,
  });

  factory PresentationGenerateState.initial() =>
      const PresentationGenerateState();

  factory PresentationGenerateState.outlineLoading() =>
      const PresentationGenerateState(isOutlineGenerating: true);

  factory PresentationGenerateState.presentationLoading() =>
      const PresentationGenerateState(isPresentationGenerating: true);

  factory PresentationGenerateState.outlineSuccess(
    String outlineResponse,
    String requestId,
  ) => PresentationGenerateState(
    outlineResponse: outlineResponse,
    lastProcessedOutlineRequestId: requestId,
  );

  factory PresentationGenerateState.presentationSuccess(
    String presentationResponse,
    String requestId,
  ) => PresentationGenerateState(
    presentationResponse: presentationResponse,
    lastProcessedPresentationRequestId: requestId,
  );

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
    String? currentRequestId,
    String? lastProcessedOutlineRequestId,
    String? lastProcessedPresentationRequestId,
  }) {
    return PresentationGenerateState(
      outlineResponse: outlineResponse ?? this.outlineResponse,
      presentationResponse: presentationResponse ?? this.presentationResponse,
      isOutlineGenerating: isOutlineGenerating ?? this.isOutlineGenerating,
      isPresentationGenerating:
          isPresentationGenerating ?? this.isPresentationGenerating,
      error: error ?? this.error,
      currentRequestId: currentRequestId ?? this.currentRequestId,
      lastProcessedOutlineRequestId:
          lastProcessedOutlineRequestId ?? this.lastProcessedOutlineRequestId,
      lastProcessedPresentationRequestId:
          lastProcessedPresentationRequestId ??
          this.lastProcessedPresentationRequestId,
    );
  }
}
