import 'package:datn_mobile/features/generate/domain/entity/mindmap_node_content.dart';
import 'package:datn_mobile/features/generate/domain/repositories/mindmap_parser_repository.dart';
import 'package:datn_mobile/features/generate/service/mindmap_parser.dart';

/// Implementation of MindmapParserRepository that delegates to MindmapParser.
///
/// This wraps the static MindmapParser utility class to make it injectable
/// and testable through the repository pattern.
class MindmapParserRepositoryImpl implements MindmapParserRepository {
  const MindmapParserRepositoryImpl();

  @override
  MindmapNodeContent parseJsonToMindmap(String jsonString) {
    return MindmapParser.parseJsonToMindmap(jsonString);
  }

  @override
  String mindmapToJson(MindmapNodeContent mindmap) {
    return MindmapParser.mindmapToJson(mindmap);
  }

  @override
  List<String> extractLeafNodes(MindmapNodeContent mindmap) {
    return MindmapParser.extractLeafNodes(mindmap);
  }

  @override
  int countTotalNodes(MindmapNodeContent mindmap) {
    return MindmapParser.countTotalNodes(mindmap);
  }

  @override
  int getMaxDepth(MindmapNodeContent mindmap) {
    return MindmapParser.getMaxDepth(mindmap);
  }
}
