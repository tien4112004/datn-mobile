import 'package:datn_mobile/features/generate/domain/entities/ai_model.dart';
import 'package:datn_mobile/features/presentation_generate/data/dto/outline_generate_request_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/dto/presentation_generate_request_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/repository/repository_provider.dart';
import 'package:datn_mobile/features/presentation_generate/domain/entity/outline_editing_state.dart';
import 'package:datn_mobile/features/presentation_generate/domain/entity/outline_slide.dart';
import 'package:datn_mobile/features/presentation_generate/enum/presentation_theme.dart';
import 'package:datn_mobile/features/presentation_generate/service/service_provider.dart';
import 'package:datn_mobile/features/presentation_generate/states/presentation_form_state.dart';
import 'package:datn_mobile/features/presentation_generate/states/presentation_generate_state.dart';
import 'package:datn_mobile/shared/models/model_info.dart';
import 'package:datn_mobile/shared/models/slide_viewport.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'presentation_generate_controller.dart';
part 'presentation_form_controller.dart';
part 'outline_editing_controller.dart';

/// Provider for the presentation generation controller.
final presentationGenerateControllerProvider =
    AsyncNotifierProvider<
      PresentationGenerateController,
      PresentationGenerateState
    >(PresentationGenerateController.new);

/// Provider for the presentation form controller.
final presentationFormControllerProvider =
    NotifierProvider<PresentationFormController, PresentationFormState>(
      PresentationFormController.new,
    );

/// Provider for the outline editing controller.
final outlineEditingControllerProvider =
    NotifierProvider<OutlineEditingController, OutlineEditingState>(
      OutlineEditingController.new,
    );
