import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/shared/api_client/dio/dio_client_provider.dart';
import 'package:datn_mobile/features/presentation_generate/data/source/presentation_remote_source.dart';

final presentationRemoteSourceProvider = Provider<PresentationRemoteSource>((ref) {
  final dio = ref.watch(dioProvider);
  return PresentationRemoteSource(dio);
});