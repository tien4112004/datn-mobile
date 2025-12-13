import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';

/// State class representing the mindmap generation form inputs.
class MindmapFormState {
  /// The main topic for the mindmap
  final String topic;

  /// Selected AI model for generation
  final AIModel? selectedModel;

  /// Language for the mindmap content (ISO 639-1 code)
  final String language;

  /// Maximum depth of the mindmap branches (1-5)
  final int maxDepth;

  /// Maximum number of branches per node (1-10)
  final int maxBranchesPerNode;

  const MindmapFormState({
    this.topic = '',
    this.selectedModel,
    this.language = 'en',
    this.maxDepth = 3,
    this.maxBranchesPerNode = 5,
  });

  MindmapFormState copyWith({
    String? topic,
    AIModel? selectedModel,
    bool clearSelectedModel = false,
    String? language,
    int? maxDepth,
    int? maxBranchesPerNode,
  }) {
    return MindmapFormState(
      topic: topic ?? this.topic,
      selectedModel: clearSelectedModel
          ? null
          : (selectedModel ?? this.selectedModel),
      language: language ?? this.language,
      maxDepth: maxDepth ?? this.maxDepth,
      maxBranchesPerNode: maxBranchesPerNode ?? this.maxBranchesPerNode,
    );
  }

  /// Validate if form is ready for submission
  bool get isValid => topic.trim().isNotEmpty && selectedModel != null;

  /// Validate topic length
  bool get isTopicValid => topic.trim().isNotEmpty && topic.length <= 500;
}
