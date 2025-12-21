import 'package:datn_mobile/features/projects/domain/entity/image_project.dart';
import 'package:datn_mobile/features/projects/domain/entity/image_project_minimal.dart';

abstract class ImageRepository {
  Future<List<ImageProjectMinimal>> fetchImages();
  Future<ImageProject> fetchImageById(String id);
  Future<void> addImage(ImageProject image);

  Future<List<ImageProjectMinimal>> fetchImageMinimalsPaged(
    int pageKey, {
    int pageSize = 10,
    String sort = "desc",
  });
}
