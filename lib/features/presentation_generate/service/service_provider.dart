import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/features/presentation_generate/data/source/presentation_remote_source_provider.dart';
import 'package:datn_mobile/features/presentation_generate/service/presentation_service.dart';

final presentationServiceProvider = Provider<PresentationService>((ref) {
  final remoteSource = ref.watch(presentationRemoteSourceProvider);
  return PresentationService(remoteSource);
});