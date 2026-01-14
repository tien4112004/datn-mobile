import 'package:datn_mobile/features/projects/domain/entity/image_project.dart';
import 'package:datn_mobile/features/projects/domain/entity/image_project_minimal.dart';

abstract interface class ImageService {
  Future<List<ImageProjectMinimal>> fetchImages();
  Future<ImageProject> fetchImageById(String id);
  Future<void> addImage(ImageProject image);

  Future<List<ImageProjectMinimal>> fetchImageMinimalsPaged(
    int pageKey, {
    int pageSize = 10,
    String? search,
  });
}
