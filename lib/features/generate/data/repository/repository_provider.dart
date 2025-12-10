import 'package:datn_mobile/features/generate/data/repository/mindmap_repository_impl.dart';
import 'package:datn_mobile/features/generate/data/repository/mindmap_parser_repository_impl.dart';
import 'package:datn_mobile/features/generate/data/repository/models_repository_impl.dart';
import 'package:datn_mobile/features/generate/data/repository/outline_parser_repository_impl.dart';
import 'package:datn_mobile/features/generate/data/repository/presentation_generate_repository_impl.dart';
import 'package:datn_mobile/features/generate/data/source/mindmap_remote_source_provider.dart';
import 'package:datn_mobile/features/generate/data/source/presentation_generate_remote_source_provider.dart';
import 'package:datn_mobile/features/generate/domain/repositories/models_repository.dart';
import 'package:datn_mobile/features/generate/data/source/models_remote_source_provider.dart';
import 'package:datn_mobile/features/generate/domain/repositories/mindmap_parser_repository.dart';
import 'package:datn_mobile/features/generate/domain/repositories/outline_parser_repository.dart';
import 'package:datn_mobile/features/generate/domain/repository/mindmap_repository.dart';
import 'package:datn_mobile/features/generate/domain/repository/presentation_generate_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for ModelsRepository - Uses real API implementation
final modelsRepositoryProvider = Provider<ModelsRepository>((ref) {
  return ModelsRepositoryImpl(ref.watch(modelsRemoteSourceProvider));
});

final presentationGenerateRepositoryProvider =
    Provider<PresentationGenerateRepository>((ref) {
      return PresentationGenerateRepositoryImpl(
        ref.read(presentationGenerateRemoteSourceProvider),
      );
    });

final outlineParserRepositoryProvider = Provider<OutlineParserRepository>((
  ref,
) {
  return const OutlineParserRepositoryImpl();
});

final mindmapParserRepositoryProvider = Provider<MindmapParserRepository>((
  ref,
) {
  return const MindmapParserRepositoryImpl();
});

/// Provider for MindmapRepository
final mindmapRepositoryProvider = Provider<MindmapRepository>((ref) {
  return MindmapRepositoryImpl(ref.watch(mindmapRemoteSourceProvider));
});
