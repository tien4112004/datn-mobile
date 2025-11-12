import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/features/presentation_generate/domain/entity/presentation_entity.dart';
import 'package:datn_mobile/features/presentation_generate/enum/presentation_enums.dart';
import 'package:datn_mobile/features/presentation_generate/service/service_provider.dart';

part 'presentation_controller.dart';

final presentationFormControllerProvider =
    NotifierProvider<PresentationFormController, PresentationRequest>(
  () => PresentationFormController(),
);

final generatePresentationControllerProvider =
    AsyncNotifierProvider<GeneratePresentationController, void>(
  () => GeneratePresentationController(),
);