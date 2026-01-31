part of 'service_provider.dart';

class ImageServiceImpl implements ImageService {
  final ImageRepository _repo;
  ImageServiceImpl(this._repo);

  @override
  Future<List<ImageProjectMinimal>> fetchImages() {
    return _repo.fetchImages();
  }

  @override
  Future<ImageProject> fetchImageById(String id) {
    return _repo.fetchImageById(id);
  }

  @override
  Future<void> addImage(ImageProject image) {
    // Additional validations or logics
    return _repo.addImage(image);
  }

  @override
  Future<List<ImageProjectMinimal>> fetchImageMinimalsPaged(
    int pageKey, {
    int pageSize = 10,
    String? search,
    String? sort,
  }) {
    return _repo.fetchImageMinimalsPaged(
      pageKey,
      pageSize: pageSize,
      search: search,
      sort: sort,
    );
  }
}
