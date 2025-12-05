part of 'repository_provider.dart';

class PresentationGenerateRepositoryImpl
    implements PresentationGenerateRepository {
  final PresentationGenerateRemoteSource _remoteSource;

  PresentationGenerateRepositoryImpl(this._remoteSource);

  @override
  Future<OutlineGenerateResponse> generateOutline(
    OutlineGenerateRequest outlineData,
  ) async {
    final response = await _remoteSource.generateOutline(outlineData);

    if (response.data == null) {
      throw Exception('Failed to generate outline');
    }

    return response.data!;
  }

  @override
  Future<PresentationGenerateResponse> generatePresentation(
    PresentationGenerateRequest request,
  ) async {
    final response = await _remoteSource.generatePresentation(request);

    if (response.data == null) {
      throw Exception('Failed to generate presentation');
    }

    return response.data!;
  }
}
