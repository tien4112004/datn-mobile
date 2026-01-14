part of 'repository_provider.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ProjectsRemoteSource _remoteSource;
  ImageRepositoryImpl(this._remoteSource);

  @override
  Future<void> addImage(ImageProject image) async {
    _remoteSource.createImage(image.toDto());
  }

  @override
  Future<List<ImageProjectMinimal>> fetchImages() async {
    final dtoResponse = await _remoteSource.fetchImages();

    return dtoResponse.data?.map((dto) => dto.toEntity()).toList() ?? [];
  }

  @override
  Future<ImageProject> fetchImageById(String id) async {
    final dtoResponse = await _remoteSource.fetchImageById(int.parse(id));

    if (dtoResponse.data == null) {
      throw Exception('Image not found');
    }

    return dtoResponse.data!.toEntity();
  }

  @override
  Future<List<ImageProjectMinimal>> fetchImageMinimalsPaged(
    int pageKey, {
    int pageSize = 10,
    String? search,
  }) async {
    final dtoResponse = await _remoteSource.fetchImages(
      page: pageKey,
      size: pageSize,
      search: search,
    );

    return dtoResponse.data?.map((dto) => dto.toEntity()).toList() ?? [];
  }
}
