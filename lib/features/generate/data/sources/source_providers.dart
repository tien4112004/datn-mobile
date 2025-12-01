import 'package:datn_mobile/features/generate/data/sources/generation_remote_source.dart';
import 'package:datn_mobile/features/generate/data/sources/models_remote_source.dart';
import 'package:datn_mobile/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for ModelsRemoteSource
final modelsRemoteSourceProvider = Provider<ModelsRemoteSource>((ref) {
  final dio = ref.watch(dioPod);
  return ModelsRemoteSource(dio);
});

/// Provider for GenerationRemoteSource
final generationRemoteSourceProvider = Provider<GenerationRemoteSource>((ref) {
  final dio = ref.watch(dioPod);
  return GenerationRemoteSource(dio);
});
