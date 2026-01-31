import 'package:AIPrimary/features/projects/domain/entity/image_project.dart';
import 'package:AIPrimary/features/projects/domain/entity/image_project_minimal.dart';
import 'package:AIPrimary/features/projects/service/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageByIdProvider = FutureProvider.family
    .autoDispose<ImageProject, String>((ref, imageId) async {
      return ref.read(imageServiceProvider).fetchImageById(imageId);
    });

/// Provider to fetch all images for gallery
final allImagesProvider = FutureProvider.autoDispose<List<ImageProjectMinimal>>((
  ref,
) async {
  final service = ref.read(imageServiceProvider);
  // Fetch a large number of images for the gallery (adjust page size as needed)
  return service.fetchImageMinimalsPaged(1, pageSize: 100);
});
