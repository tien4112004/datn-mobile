part of 'service_provider.dart';

class MindmapServiceImpl implements MindmapService {
  final MindmapRepository _repository;

  MindmapServiceImpl(this._repository);

  @override
  Future<MindmapNodeContent> generateMindmap({
    required String topic,
    required AIModel model,
    required String language,
    int? maxDepth,
    int? maxBranchesPerNode,
    String? grade,
    String? subject,
    List<String>? fileUrls,
  }) async {
    // Add business logic validations here
    if (topic.trim().isEmpty && (fileUrls == null || fileUrls.isEmpty)) {
      throw ArgumentError('Topic cannot be empty');
    }

    if (topic.length > 500) {
      throw ArgumentError('Topic cannot exceed 500 characters');
    }

    if (maxDepth != null && (maxDepth < 1 || maxDepth > 5)) {
      throw ArgumentError('Max depth must be between 1 and 5');
    }

    if (maxBranchesPerNode != null &&
        (maxBranchesPerNode < 1 || maxBranchesPerNode > 10)) {
      throw ArgumentError('Max branches per node must be between 1 and 10');
    }

    // Build the request with validated parameters
    final request = MindmapGenerateRequestDto(
      topic: topic.trim(),
      model: model.name,
      provider: model.provider,
      language: language,
      maxDepth: maxDepth,
      maxBranchesPerNode: maxBranchesPerNode,
      grade: grade,
      subject: subject,
      fileUrls: fileUrls,
    );

    // Call the repository to generate mindmap via API
    return _repository.generateMindmap(request);
  }
}
