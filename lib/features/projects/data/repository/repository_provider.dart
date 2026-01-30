import 'package:AIPrimary/features/projects/data/source/projects_remote_source.dart';
import 'package:AIPrimary/features/projects/data/source/projects_remote_source_provider.dart';
import 'package:AIPrimary/features/projects/domain/repository/image_repository.dart';
import 'package:AIPrimary/features/projects/domain/repository/mindmap_repository.dart';
import 'package:AIPrimary/features/projects/domain/repository/presentation_repository.dart';
import 'package:AIPrimary/features/projects/domain/repository/recent_document_repository.dart';
import 'package:AIPrimary/features/projects/domain/repository/shared_resource_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/projects/data/dto/mindmap_dto.dart';
import 'package:AIPrimary/features/projects/data/dto/mindmap_minimal_dto.dart';
import 'package:AIPrimary/features/projects/data/dto/image_project_dto.dart';
import 'package:AIPrimary/features/projects/data/dto/image_project_minimal_dto.dart';
import 'package:AIPrimary/features/projects/data/dto/presentation_dto.dart';
import 'package:AIPrimary/features/projects/data/dto/presentation_minimal_dto.dart';
import 'package:AIPrimary/features/projects/data/dto/recent_document_dto.dart';
import 'package:AIPrimary/features/projects/data/dto/shared_resource_dto.dart';
import 'package:AIPrimary/features/projects/domain/entity/image_project.dart';
import 'package:AIPrimary/features/projects/domain/entity/image_project_minimal.dart';
import 'package:AIPrimary/features/projects/domain/entity/mindmap.dart';
import 'package:AIPrimary/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:AIPrimary/features/projects/domain/entity/presentation.dart';
import 'package:AIPrimary/features/projects/domain/entity/presentation_minimal.dart';
import 'package:AIPrimary/features/projects/domain/entity/recent_document.dart';
import 'package:AIPrimary/features/projects/domain/entity/shared_resource.dart';

part 'presentation_repository_impl.dart';
part 'mindmap_repository_impl.dart';
part 'image_repository_impl.dart';
part 'recent_document_repository_impl.dart';
part 'shared_resource_repository_impl.dart';

// Use the mock implementation for testing or development
final presentationRepositoryProvider = Provider<PresentationRepository>(
  (ref) => PresentationRepositoryImpl(ref.read(projectsRemoteSourceProvider)),
);

// Image Repository Provider
final imageRepositoryProvider = Provider<ImageRepository>(
  (ref) => ImageRepositoryImpl(ref.read(projectsRemoteSourceProvider)),
);

final mindmapRepositoryProvider = Provider<MindmapRepository>(
  (ref) => MindmapRepositoryImpl(ref.read(projectsRemoteSourceProvider)),
);

// Recent Document Repository Provider
final recentDocumentRepositoryProvider = Provider<RecentDocumentRepository>(
  (ref) => RecentDocumentRepositoryImpl(ref.read(projectsRemoteSourceProvider)),
);

// Shared Resource Repository Provider
final sharedResourceRepositoryProvider = Provider<SharedResourceRepository>(
  (ref) => SharedResourceRepositoryImpl(ref.read(projectsRemoteSourceProvider)),
);
