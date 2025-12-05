import 'package:datn_mobile/features/presentation_generate/data/dto/outline_generate_response_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/dto/presentation_generate_response_dto.dart';

/// State class representing the presentation generation form state.
class PresentationGenerateState {
  final OutlineGenerateResponse? outlineResponse;
  final PresentationGenerateResponse? presentationResponse;
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

  factory PresentationGenerateState.outlineSuccess(
    OutlineGenerateResponse outlineResponse,
  ) => PresentationGenerateState(outlineResponse: outlineResponse);

  factory PresentationGenerateState.presentationSuccess(
    PresentationGenerateResponse presentationResponse,
  ) => PresentationGenerateState(presentationResponse: presentationResponse);

  factory PresentationGenerateState.failure(Object error) =>
      PresentationGenerateState(error: error);

  bool get hasOutline => outlineResponse != null;
  bool get hasPresentation => presentationResponse != null;
  bool get isLoading => isOutlineGenerating || isPresentationGenerating;
  bool get hasError => error != null;

  PresentationGenerateState copyWith({
    OutlineGenerateResponse? outlineResponse,
    PresentationGenerateResponse? presentationResponse,
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
