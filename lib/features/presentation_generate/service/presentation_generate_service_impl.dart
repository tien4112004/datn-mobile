part of 'service_provider.dart';

class PresentationGenerateServiceImpl implements PresentationGenerateService {
  final PresentationGenerateRepository _repository;

  PresentationGenerateServiceImpl(this._repository);

  @override
  Future<OutlineGenerateResponse> generateOutline(
    OutlineGenerateRequest outlineData,
  ) async {
    // Add business logic validations here
    if (outlineData.topic.trim().isEmpty) {
      throw ArgumentError('Topic cannot be empty');
    }

    if (outlineData.slideCount < 1) {
      throw ArgumentError('Slide count must be at least 1');
    }

    return _repository.generateOutline(outlineData);
  }

  @override
  Future<PresentationGenerateResponse> generatePresentation(
    PresentationGenerateRequest request,
  ) async {
    // Add business logic validations here
    if (request.outline.trim().isEmpty) {
      throw ArgumentError('Outline cannot be empty');
    }

    if (request.slideCount < 1) {
      throw ArgumentError('Slides count must be at least 1');
    }

    return _repository.generatePresentation(request);
  }
}
