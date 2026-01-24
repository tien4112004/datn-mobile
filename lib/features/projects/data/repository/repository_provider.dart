import 'package:datn_mobile/features/projects/data/source/projects_remote_source.dart';
import 'package:datn_mobile/features/projects/data/source/projects_remote_source_provider.dart';
import 'package:datn_mobile/features/projects/domain/repository/image_repository.dart';
import 'package:datn_mobile/features/projects/domain/repository/mindmap_repository.dart';
import 'package:datn_mobile/features/projects/domain/repository/presentation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/features/projects/data/dto/mindmap_dto.dart';
import 'package:datn_mobile/features/projects/data/dto/mindmap_minimal_dto.dart';
import 'package:datn_mobile/features/projects/data/dto/image_project_dto.dart';
import 'package:datn_mobile/features/projects/data/dto/image_project_minimal_dto.dart';
import 'package:datn_mobile/features/projects/data/dto/presentation_dto.dart';
import 'package:datn_mobile/features/projects/data/dto/presentation_minimal_dto.dart';
import 'package:datn_mobile/features/projects/domain/entity/image_project.dart';
import 'package:datn_mobile/features/projects/domain/entity/image_project_minimal.dart';
import 'package:datn_mobile/features/projects/domain/entity/mindmap.dart';
import 'package:datn_mobile/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:datn_mobile/features/projects/domain/entity/presentation.dart';
import 'package:datn_mobile/features/projects/domain/entity/presentation_minimal.dart';

part 'presentation_repository_impl.dart';
part 'mindmap_repository_impl.dart';
part 'image_repository_impl.dart';

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
