import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/features/presentation_generate/presentation_generation/data/source/presentation_generation_remote_source_provider.dart';
import 'package:datn_mobile/features/presentation_generate/presentation_generation/service/presentation_generation_service.dart';

final presentationGenerationServiceProvider =
    Provider<PresentationGenerationService>((ref) {
      final remoteSource = ref.watch(
        presentationGenerationRemoteSourceProvider,
      );
      return PresentationGenerationService(remoteSource);
    });
