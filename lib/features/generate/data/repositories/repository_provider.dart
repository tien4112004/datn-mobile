import 'package:datn_mobile/features/generate/data/repositories/generation_repository_impl.dart';
import 'package:datn_mobile/features/generate/data/repositories/models_repository_impl.dart';
import 'package:datn_mobile/features/generate/data/sources/source_providers.dart';
import 'package:datn_mobile/features/generate/domain/repositories/generation_repository.dart';
import 'package:datn_mobile/features/generate/domain/repositories/models_repository.dart';
import 'package:datn_mobile/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for ModelsRepository - Uses real API implementation
final modelsRepositoryProvider = Provider<ModelsRepository>((ref) {
  return ModelsRepositoryImpl(ref.watch(modelsRemoteSourceProvider));
});

/// Provider for GenerationRepository - Uses real API implementation
final generationRepositoryProvider = Provider<GenerationRepository>((ref) {
  return GenerationRepositoryImpl(ref.watch(dioPod));
});
