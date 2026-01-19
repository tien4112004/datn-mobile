part of 'repository_provider.dart';

class PresentationRepositoryImpl implements PresentationRepository {
  final ProjectsRemoteSource _remoteSource;
  PresentationRepositoryImpl(this._remoteSource);

  @override
  Future<void> addPresentation(Presentation presentation) {
    // This mapper was created in the presentation_dto.dart as a extension method.
    // PresentationDto presentationDto = presentation.toDto();
    // LOGIC...
    _remoteSource.createPresentation(presentation.toDto());
    throw UnimplementedError();
  }

  @override
  Future<List<PresentationMinimal>> fetchPresentations() async {
    final dtoResponse = await _remoteSource.fetchPresentations();

    return dtoResponse.data?.map((dto) => dto.toEntity()).toList() ?? [];
    // Implementation details would go here
  }

  @override
  Future<Presentation> fetchPresentationById(String id) async {
    final dtoResponse = await _remoteSource.fetchPresentationById(id);

    if (dtoResponse.data == null) {
      throw Exception('Presentation not found');
    }

    return dtoResponse.data!.toEntity();
  }

  @override
  Future<List<PresentationMinimal>> fetchPresentationMinimalsPaged(
    int pageKey, {
    int pageSize = 10,
    String sort = "desc",
    String? search,
  }) {
    return _remoteSource
        .fetchPresentationMinimalsPaged(
          pageKey: pageKey,
          pageSize: pageSize,
          sort: sort,
          search: search,
        )
        .then(
          (dtoResponse) =>
              dtoResponse.data?.map((dto) => dto.toEntity()).toList() ?? [],
        );
  }
}
