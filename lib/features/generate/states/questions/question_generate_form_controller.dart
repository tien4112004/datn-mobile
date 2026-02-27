part of '../controller_provider.dart';

/// Controller for managing the question generation form state.
///
/// State is kept alive via the provider to prevent loss when navigating
/// to/from advanced settings sheets or other overlays.
class QuestionGenerateFormController
    extends Notifier<QuestionGenerateFormState> {
  @override
  QuestionGenerateFormState build() {
    // Load persisted model preference
    final prefs = ref.read(generationPreferencesServiceProvider);
    final savedModelId = prefs.getQuestionTextModelId();
    if (savedModelId != null) {
      ref.listen(modelsControllerPod(ModelType.text), (_, next) {
        next.whenData((state) {
          final model = state.availableModels
              .where((m) => m.id == savedModelId)
              .firstOrNull;
          if (model != null) {
            updateModel(model);
          }
        });
      });
    }

    return QuestionGenerateFormState();
  }

  void updateTopic(String topic) {
    state = state.copyWith(topic: topic);
  }

  void updateGrade(GradeLevel grade) {
    state = state.copyWith(grade: grade, clearChapter: true);
  }

  void updateSubject(Subject subject) {
    state = state.copyWith(subject: subject, clearChapter: true);
  }

  void updateChapter(String? chapter) {
    state = state.copyWith(chapter: chapter, clearChapter: chapter == null);
  }

  void updateSelectedTypes(Set<QuestionType> types) {
    state = state.copyWith(selectedTypes: Set.from(types));
  }

  void updateDifficultyCounts(Map<Difficulty, int> counts) {
    state = state.copyWith(difficultyCounts: Map.from(counts));
  }

  void updateModel(AIModel model) {
    state = state.copyWith(selectedModel: model);
    ref
        .read(generationPreferencesServiceProvider)
        .saveQuestionTextModelId(model.id);
  }

  void updatePrompt(String prompt) {
    state = state.copyWith(prompt: prompt);
  }

  void reset() {
    state = QuestionGenerateFormState(selectedModel: state.selectedModel);
  }

  GenerateQuestionsRequestEntity toRequestEntity() {
    return GenerateQuestionsRequestEntity(
      topic: state.topic,
      grade: state.grade,
      subject: state.subject,
      questionsPerDifficulty: state.activeQuestionsPerDifficulty,
      questionTypes: state.selectedTypes.toList(),
      provider: state.selectedModel?.provider,
      model: state.selectedModel?.name,
      prompt: state.prompt.trim().isEmpty ? null : state.prompt.trim(),
      chapter: state.chapter,
    );
  }
}
