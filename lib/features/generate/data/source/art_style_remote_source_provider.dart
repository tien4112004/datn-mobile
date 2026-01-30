import 'package:AIPrimary/features/generate/data/source/art_style_remote_source.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for ArtStyleRemoteSource
final artStyleRemoteSourceProvider = Provider<ArtStyleRemoteSource>((ref) {
  final dio = ref.watch(dioPod);
  return ArtStyleRemoteSource(dio);
});
