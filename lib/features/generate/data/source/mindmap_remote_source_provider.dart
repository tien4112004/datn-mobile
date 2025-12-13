import 'package:datn_mobile/features/generate/data/source/mindmap_remote_source.dart';
import 'package:datn_mobile/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for MindmapRemoteSource
final mindmapRemoteSourceProvider = Provider<MindmapRemoteSource>((ref) {
  final dio = ref.watch(dioPod);
  return MindmapRemoteSource(dio);
});
