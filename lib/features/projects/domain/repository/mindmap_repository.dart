import 'package:datn_mobile/features/projects/domain/entity/mindmap.dart';
import 'package:datn_mobile/features/projects/domain/entity/mindmap_minimal.dart';

abstract class MindmapRepository {
  Future<List<MindmapMinimal>> fetchMindmaps();

  Future<Mindmap> fetchMindmapById(String id);

  Future<List<MindmapMinimal>> fetchMindmapMinimalsPaged(
    int pageKey, {
    int pageSize = 10,
    String sort = "desc",
  });
}
