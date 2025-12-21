import 'package:datn_mobile/features/projects/data/repository/repository_provider.dart';
import 'package:datn_mobile/features/projects/domain/entity/image_project.dart';
import 'package:datn_mobile/features/projects/domain/entity/mindmap.dart';
import 'package:datn_mobile/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:datn_mobile/features/projects/domain/entity/presentation.dart';
import 'package:datn_mobile/features/projects/domain/entity/presentation_minimal.dart';
import 'package:datn_mobile/features/projects/service/service_provider.dart';
import 'package:datn_mobile/features/projects/states/mindmap_list_state.dart';
import 'package:datn_mobile/features/projects/states/presentation_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'presentation_controller.dart';
part 'mindmap_controller.dart';

final presentationsControllerProvider =
    AsyncNotifierProvider<PresentationsController, PresentationListState>(
      () => PresentationsController(),
    );

final presentationByIdProvider = FutureProvider.family<Presentation, String>((
  ref,
  id,
) async {
  return ref.read(presentationServiceProvider).fetchPresentationById(id);
});

final createPresentationControllerProvider =
    AsyncNotifierProvider<CreatePresentationController, void>(
      () => CreatePresentationController(),
    );

// Image Providers
final imageByIdProvider = FutureProvider.family<ImageProject, String>((
  ref,
  id,
) async {
  final images = await ref
      .read(imageServiceProvider)
      .fetchImageMinimalsPaged(1);
  return ImageProject(
    id: id,
    title: images.firstWhere((image) => image.id == id).title,
    imageUrl: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
});

final mindmapsControllerProvider =
    AsyncNotifierProvider<MindmapsController, MindmapListState>(
      () => MindmapsController(),
    );

final mindmapByIdProvider = FutureProvider.family<Mindmap, String>((
  ref,
  id,
) async {
  return ref.read(mindmapServiceProvider).fetchMindmapById(id);
});
