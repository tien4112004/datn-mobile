import 'package:AIPrimary/features/projects/domain/entity/image_project.dart';
import 'package:AIPrimary/features/projects/domain/entity/image_project_minimal.dart';

abstract class ImageRepository {
  Future<List<ImageProjectMinimal>> fetchImages();
  Future<ImageProject> fetchImageById(String id);
  Future<void> addImage(ImageProject image);

  Future<List<ImageProjectMinimal>> fetchImageMinimalsPaged(
    int pageKey, {
    int pageSize = 10,
    String? search,
    String? sort,
  });
}
