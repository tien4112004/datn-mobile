import 'package:datn_mobile/features/generate/data/dto/outline_generate_request_dto.dart';
import 'package:datn_mobile/features/generate/data/dto/presentation_generate_request_dto.dart';
import 'package:datn_mobile/features/generate/data/repository/repository_provider.dart';
import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';
import 'package:datn_mobile/features/generate/domain/entity/outline_editing_state.dart';
import 'package:datn_mobile/features/generate/domain/entity/outline_slide.dart';
import 'package:datn_mobile/features/generate/enum/generator_type.dart';
import 'package:datn_mobile/features/generate/enum/presentation_theme.dart';
import 'package:datn_mobile/features/generate/service/service_provider.dart';
import 'package:datn_mobile/features/generate/states/image/image_form_state.dart';
import 'package:datn_mobile/features/generate/states/image/image_generate_state.dart';
import 'package:datn_mobile/features/generate/states/mindmap/mindmap_form_state.dart';
import 'package:datn_mobile/features/generate/states/mindmap/mindmap_generate_state.dart';
import 'package:datn_mobile/features/generate/states/presentations/presentation_form_state.dart';
import 'package:datn_mobile/features/generate/states/presentations/presentation_generate_state.dart';
import 'package:datn_mobile/features/generate/ui/widgets/options/image_widget_options.dart';
import 'package:datn_mobile/shared/models/model_info.dart';
import 'package:datn_mobile/shared/models/slide_viewport.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/features/generate/states/models/models_controller.dart';
import 'package:datn_mobile/features/generate/states/models/image_model_state.dart';
import 'package:datn_mobile/features/generate/states/models/models_state.dart';
import 'package:datn_mobile/features/generate/states/models/text_model_state.dart';
import 'package:flutter_riverpod/legacy.dart';

part 'image/image_form_controller.dart';
part 'image/image_generate_controller.dart';
part 'presentations/presentation_generate_controller.dart';
part 'presentations/presentation_form_controller.dart';
part 'outline/outline_editing_controller.dart';
part 'mindmap/mindmap_form_controller.dart';
part 'mindmap/mindmap_generate_controller.dart';
part 'models/models_pod.dart';

/// Provider for the presentation generation controller.
final presentationGenerateControllerProvider =
    AsyncNotifierProvider<
      PresentationGenerateController,
      PresentationGenerateState
    >(PresentationGenerateController.new);

/// Provider for the presentation form controller.
final presentationFormControllerProvider =
    NotifierProvider.autoDispose<
      PresentationFormController,
      PresentationFormState
    >(PresentationFormController.new);

/// Provider for the outline editing controller.
final outlineEditingControllerProvider =
    NotifierProvider<OutlineEditingController, OutlineEditingState>(
      OutlineEditingController.new,
    );

/// Provider for the mindmap form controller.
final mindmapFormControllerProvider =
    NotifierProvider<MindmapFormController, MindmapFormState>(
      MindmapFormController.new,
    );

/// Provider for the mindmap generation controller.
final mindmapGenerateControllerProvider =
    AsyncNotifierProvider<MindmapGenerateController, MindmapGenerateState>(
      MindmapGenerateController.new,
    );

/// Provider for the image form controller.
final imageFormControllerProvider =
    NotifierProvider<ImageFormController, ImageFormState>(
      ImageFormController.new,
    );

/// Provider for the image generation controller.
final imageGenerateControllerProvider =
    AsyncNotifierProvider<ImageGenerateController, ImageGenerateState>(
      ImageGenerateController.new,
    );

/// Provider for tracking the active generator type.
/// Defaults to presentation generator.
final generatorTypeProvider = StateProvider<GeneratorType>((ref) {
  return GeneratorType.presentation;
});
