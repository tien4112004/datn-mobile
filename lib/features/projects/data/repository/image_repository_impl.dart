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
    final dtoResponse = await _remoteSource.fetchImageById(id);

    if (dtoResponse.data == null) {
      throw Exception('Image not found');
    }

    return dtoResponse.data!.toEntity();
  }

  @override
  Future<List<ImageProjectMinimal>> fetchImageMinimalsPaged(
    int pageKey, {
    int pageSize = 10,
    String sort = "desc",
  }) {
    // return _remoteSource
    //     .fetchImageMinimalsPaged(
    //       pageKey: pageKey,
    //       pageSize: pageSize,
    //       sort: sort,
    //     )
    //     .then(
    //       (dtoResponse) =>
    //           dtoResponse.data?.map((dto) => dto.toEntity()).toList() ?? [],
    //     );

    // Mock images
    return Future.value(
      List.generate(
        pageSize,
        (index) => ImageProjectMinimal(
          id: 'img_${(pageKey - 1) * pageSize + index + 1}',
          title: 'Image ${(pageKey - 1) * pageSize + index + 1}',
          imageUrl: 'https://picsum.photos/300/200',
        ),
      ),
    );
  }
}
