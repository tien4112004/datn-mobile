import 'package:AIPrimary/features/projects/data/repository/repository_provider.dart';
import 'package:AIPrimary/features/projects/domain/service/image_service.dart';
import 'package:AIPrimary/features/projects/domain/entity/mindmap.dart';
import 'package:AIPrimary/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:AIPrimary/features/projects/domain/entity/image_project.dart';
import 'package:AIPrimary/features/projects/domain/entity/image_project_minimal.dart';
import 'package:AIPrimary/features/projects/domain/entity/presentation.dart';
import 'package:AIPrimary/features/projects/domain/entity/presentation_minimal.dart';
import 'package:AIPrimary/features/projects/domain/entity/recent_document.dart';
import 'package:AIPrimary/features/projects/domain/entity/shared_resource.dart';
import 'package:AIPrimary/features/projects/domain/repository/image_repository.dart';
import 'package:AIPrimary/features/projects/domain/repository/mindmap_repository.dart';
import 'package:AIPrimary/features/projects/domain/repository/presentation_repository.dart';
import 'package:AIPrimary/features/projects/domain/repository/recent_document_repository.dart';
import 'package:AIPrimary/features/projects/domain/repository/shared_resource_repository.dart';
import 'package:AIPrimary/features/projects/domain/service/mindmap_service.dart';
import 'package:AIPrimary/features/projects/domain/service/presentation_service.dart';
import 'package:AIPrimary/features/projects/domain/service/recent_document_service.dart';
import 'package:AIPrimary/features/projects/domain/service/shared_resource_service.dart';
import 'package:AIPrimary/features/projects/enum/sort_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'presentation_service_impl.dart';
part 'image_service_impl.dart';
part 'mindmap_service_impl.dart';
part 'recent_document_service_impl.dart';
part 'shared_resource_service_impl.dart';

final presentationServiceProvider = Provider<PresentationService>((ref) {
  return PresentationServiceImpl(ref.read(presentationRepositoryProvider));
});

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageServiceImpl(ref.read(imageRepositoryProvider));
});

final mindmapServiceProvider = Provider<MindmapService>((ref) {
  return MindmapServiceImpl(ref.read(mindmapRepositoryProvider));
});

final recentDocumentServiceProvider = Provider<RecentDocumentService>((ref) {
  return RecentDocumentServiceImpl(ref.read(recentDocumentRepositoryProvider));
});

final sharedResourceServiceProvider = Provider<SharedResourceService>((ref) {
  return SharedResourceServiceImpl(ref.read(sharedResourceRepositoryProvider));
});
