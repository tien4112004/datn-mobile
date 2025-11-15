import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/shared/api_client/dio/dio_client_provider.dart';
import 'package:datn_mobile/features/presentation_generate/outline_generation/data/source/outline_remote_source_provider.dart';
import 'package:datn_mobile/features/presentation_generate/outline_generation/service/outline_service.dart';

final outlineServiceProvider = Provider<OutlineService>((ref) {
  final remoteSource = ref.watch(outlineRemoteSourceProvider);
  final dio = ref.watch(dioProvider);
  return OutlineService(remoteSource, dio);
});
