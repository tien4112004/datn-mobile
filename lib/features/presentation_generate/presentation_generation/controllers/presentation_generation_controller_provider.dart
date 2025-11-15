import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/features/presentation_generate/presentation_generation/domain/entity/presentation_generation_entity.dart';
import 'package:datn_mobile/features/presentation_generate/presentation_generation/service/presentation_generation_service_provider.dart';

part 'presentation_generation_controller.dart';

final presentationGenerationFormControllerProvider =
    NotifierProvider<
      PresentationGenerationFormController,
      PresentationGenerationRequest
    >(() => PresentationGenerationFormController());

final generatePresentationControllerProvider =
    AsyncNotifierProvider<
      GeneratePresentationController,
      PresentationGenerationResponse?
    >(() => GeneratePresentationController());
