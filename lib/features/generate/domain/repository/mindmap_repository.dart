import 'package:datn_mobile/features/generate/data/dto/mindmap_generate_request_dto.dart';
import 'package:datn_mobile/features/generate/domain/entity/mindmap_node_content.dart';

/// Abstract repository for mindmap generation operations.
abstract class MindmapRepository {
  /// Generates a mindmap from a topic using AI.
  Future<MindmapNodeContent> generateMindmap(MindmapGenerateRequestDto request);
}
