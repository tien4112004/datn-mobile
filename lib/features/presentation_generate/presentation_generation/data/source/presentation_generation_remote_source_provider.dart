import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/shared/api_client/dio/dio_client_provider.dart';
import 'package:datn_mobile/features/presentation_generate/presentation_generation/data/source/presentation_generation_remote_source.dart';

final presentationGenerationRemoteSourceProvider =
    Provider<PresentationGenerationRemoteSource>((ref) {
      final dio = ref.watch(dioProvider);
      return PresentationGenerationRemoteSource(dio);
    });
