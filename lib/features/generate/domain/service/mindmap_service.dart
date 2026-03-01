import 'package:AIPrimary/features/generate/domain/entity/ai_model.dart';
import 'package:AIPrimary/features/generate/domain/entity/mindmap_node_content.dart';

/// Abstract service interface for mindmap generation.
abstract interface class MindmapService {
  /// Generates a mindmap from a topic using AI.
  Future<MindmapNodeContent> generateMindmap({
    required String topic,
    required AIModel model,
    required String language,
    int? maxDepth,
    int? maxBranchesPerNode,
    String? grade,
    String? subject,
    List<String>? fileUrls,
  });
}
