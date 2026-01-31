import 'package:AIPrimary/features/generate/data/source/image_remote_source.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for ImageRemoteSource
final imageRemoteSourceProvider = Provider<ImageRemoteSource>((ref) {
  final dio = ref.watch(dioPod);
  return ImageRemoteSource(dio);
});
