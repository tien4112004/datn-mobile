import 'package:AIPrimary/features/generate/data/dto/outline_generate_request_dto.dart';
import 'package:AIPrimary/features/generate/data/dto/presentation_generate_request_dto.dart';
import 'package:AIPrimary/features/generate/data/repository/repository_provider.dart';
import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';
import 'package:AIPrimary/features/generate/domain/entity/outline_editing_state.dart';
import 'package:AIPrimary/features/generate/domain/entity/outline_slide.dart';
import 'package:AIPrimary/features/generate/enum/generator_type.dart';
import 'package:AIPrimary/features/generate/enum/presentation_theme.dart';
import 'package:AIPrimary/features/generate/service/generation_preferences_service.dart';
import 'package:AIPrimary/features/generate/service/service_provider.dart';
import 'package:AIPrimary/features/generate/states/image/image_form_state.dart';
import 'package:AIPrimary/features/generate/states/image/image_generate_state.dart';
import 'package:AIPrimary/features/generate/states/mindmap/mindmap_form_state.dart';
import 'package:AIPrimary/features/generate/states/mindmap/mindmap_generate_state.dart';
import 'package:AIPrimary/features/generate/states/presentations/presentation_form_state.dart';
import 'package:AIPrimary/features/generate/states/presentations/presentation_generate_state.dart';
import 'package:AIPrimary/features/generate/states/questions/question_generate_form_state.dart';
import 'package:AIPrimary/features/questions/states/question_generation_provider.dart';
import 'package:AIPrimary/features/questions/states/question_generation_state.dart';
import 'package:AIPrimary/features/generate/states/theme/theme_provider.dart';
import 'package:AIPrimary/features/questions/domain/entity/generate_questions_request_entity.dart';
import 'package:AIPrimary/shared/models/cms_enums.dart';
import 'package:AIPrimary/shared/models/model_info.dart';
import 'package:AIPrimary/shared/models/slide_viewport.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:AIPrimary/features/generate/states/models/models_controller.dart';
import 'package:AIPrimary/features/generate/states/models/image_model_state.dart';
import 'package:AIPrimary/features/generate/states/models/models_state.dart';
import 'package:AIPrimary/features/generate/states/models/text_model_state.dart';
import 'package:flutter_riverpod/legacy.dart';

part 'image/image_form_controller.dart';
part 'image/image_generate_controller.dart';
part 'presentations/presentation_generate_controller.dart';
part 'presentations/presentation_form_controller.dart';
part 'outline/outline_editing_controller.dart';
part 'mindmap/mindmap_form_controller.dart';
part 'mindmap/mindmap_generate_controller.dart';
part 'questions/question_generate_form_controller.dart';
part 'models/models_pod.dart';

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

/// Provider for the question generate form controller.
final questionGenerateFormControllerProvider =
    NotifierProvider<QuestionGenerateFormController, QuestionGenerateFormState>(
      QuestionGenerateFormController.new,
    );

/// Thin async adapter so [TopicInputBar] can observe loading state from the
/// question [StateNotifierProvider] as an [AsyncValue].
///
/// Uses [ref.listen] to manually push [AsyncLoading] / [AsyncData] to keep
/// the outer [AsyncValue] in sync with the inner [QuestionGenerationState.isLoading].
class _QuestionGenerateAsyncNotifier
    extends AsyncNotifier<QuestionGenerationState> {
  @override
  Future<QuestionGenerationState> build() async {
    // Listen for changes and manually reflect the isLoading flag.
    ref.listen<QuestionGenerationState>(questionGenerationProvider, (
      prev,
      next,
    ) {
      if (next.isLoading) {
        state = const AsyncLoading();
      } else {
        state = AsyncData(next);
      }
    });
    // Seed with the current state (not loading on first build).
    return ref.read(questionGenerationProvider);
  }
}

final questionGenerateAsyncProvider =
    AsyncNotifierProvider<
      _QuestionGenerateAsyncNotifier,
      QuestionGenerationState
    >(_QuestionGenerateAsyncNotifier.new);

/// Provider for tracking the active generator type.
/// Defaults to presentation generator.
final generatorTypeProvider = StateProvider<GeneratorType>((ref) {
  return GeneratorType.presentation;
});
