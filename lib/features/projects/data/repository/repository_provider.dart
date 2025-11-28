import 'package:datn_mobile/features/projects/data/source/projects_remote_source.dart';
import 'package:datn_mobile/features/projects/data/source/projects_remote_source_provider.dart';
import 'package:datn_mobile/features/projects/domain/repository/presentation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/features/projects/data/dto/presentation_dto.dart';
import 'package:datn_mobile/features/projects/data/dto/presentation_minimal_dto.dart';
import 'package:datn_mobile/features/projects/domain/entity/presentation.dart';
import 'package:datn_mobile/features/projects/domain/entity/presentation_minimal.dart';

part 'presentation_repository_impl.dart';
// For example
// part 'image_repository_impl.dart';

// Uncomment the following line to use the real implementation
// final presentationRepositoryProvider = Provider<PresentationRepository>(
//   (ref) => PresentationRepositoryImpl(ref.read(projectsRemoteSourceProvider)),
// );

// Use the mock implementation for testing or development
final presentationRepositoryProvider = Provider<PresentationRepository>(
  (ref) => PresentationRepositoryImpl(ref.read(projectsRemoteSourceProvider)),
);
