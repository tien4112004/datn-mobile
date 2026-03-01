part of '../controller_provider.dart';

/// Controller for managing the mindmap form state.
class MindmapFormController extends Notifier<MindmapFormState> {
  @override
  MindmapFormState build() {
    // Load persisted preferences
    final prefs = ref.read(generationPreferencesServiceProvider);

    // Load language
    final savedLanguage = prefs.getMindmapLanguage();

    // Load text model
    final savedModelId = prefs.getMindmapTextModelId();
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

    final normalizedLanguage =
        (savedLanguage == 'vi' || savedLanguage == 'Vietnamese') ? 'vi' : 'en';
    return MindmapFormState(language: normalizedLanguage);
  }

  void updateTopic(String topic) {
    state = state.copyWith(topic: topic);
  }

  void updateModel(AIModel model) {
    state = state.copyWith(selectedModel: model);
    ref
        .read(generationPreferencesServiceProvider)
        .saveMindmapTextModelId(model.id);
  }

  void updateLanguage(String language) {
    state = state.copyWith(language: language);
    ref
        .read(generationPreferencesServiceProvider)
        .saveMindmapLanguage(language);
  }

  void updateMaxDepth(int maxDepth) {
    state = state.copyWith(maxDepth: maxDepth);
  }

  void updateMaxBranchesPerNode(int maxBranchesPerNode) {
    state = state.copyWith(maxBranchesPerNode: maxBranchesPerNode);
  }

  void updateGrade(String? grade) {
    state = state.copyWith(grade: grade, clearGrade: grade == null);
  }

  void updateSubject(String? subject) {
    state = state.copyWith(subject: subject, clearSubject: subject == null);
  }

  void addFile(String url, int bytes) {
    final updatedUrls = [...state.fileUrls, url];
    final updatedSizes = {...state.fileSizes, url: bytes};
    state = state.copyWith(fileUrls: updatedUrls, fileSizes: updatedSizes);
  }

  void removeFileUrl(String url) {
    final updatedUrls = state.fileUrls.where((u) => u != url).toList();
    final updatedSizes = {...state.fileSizes}..remove(url);
    state = state.copyWith(fileUrls: updatedUrls, fileSizes: updatedSizes);
  }

  void reset() {
    // Preserve preference-related fields, only clear user-input fields
    state = MindmapFormState(
      language: state.language,
      selectedModel: state.selectedModel,
      // User-input fields use defaults: topic='', maxDepth=3, maxBranchesPerNode=5, etc.
    );
  }
}
