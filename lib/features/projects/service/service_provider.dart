import 'package:datn_mobile/features/projects/data/repository/repository_provider.dart';
import 'package:datn_mobile/features/projects/domain/service/image_service.dart';
import 'package:datn_mobile/features/projects/domain/entity/mindmap.dart';
import 'package:datn_mobile/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:datn_mobile/features/projects/domain/entity/image_project.dart';
import 'package:datn_mobile/features/projects/domain/entity/image_project_minimal.dart';
import 'package:datn_mobile/features/projects/domain/entity/presentation.dart';
import 'package:datn_mobile/features/projects/domain/entity/presentation_minimal.dart';
import 'package:datn_mobile/features/projects/domain/repository/image_repository.dart';
import 'package:datn_mobile/features/projects/domain/repository/mindmap_repository.dart';
import 'package:datn_mobile/features/projects/domain/repository/presentation_repository.dart';
import 'package:datn_mobile/features/projects/domain/service/mindmap_service.dart';
import 'package:datn_mobile/features/projects/domain/service/presentation_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'presentation_service_impl.dart';
part 'image_service_impl.dart';
part 'mindmap_service_impl.dart';

final presentationServiceProvider = Provider<PresentationService>((ref) {
  return PresentationServiceImpl(ref.read(presentationRepositoryProvider));
});

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageServiceImpl(ref.read(imageRepositoryProvider));
});

final mindmapServiceProvider = Provider<MindmapService>((ref) {
  return MindmapServiceImpl(ref.read(mindmapRepositoryProvider));
});
