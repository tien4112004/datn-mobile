import 'package:AIPrimary/features/projects/domain/entity/mindmap.dart';
import 'package:AIPrimary/features/projects/domain/entity/mindmap_minimal.dart';
import 'package:AIPrimary/features/projects/enum/sort_option.dart';

abstract class MindmapService {
  Future<List<MindmapMinimal>> fetchMindmaps();

  Future<Mindmap> fetchMindmapById(String id);

  Future<List<MindmapMinimal>> fetchMindmapMinimalsPaged(
    int pageKey,
    int pageSize, {
    String? search,
    SortOption? sort,
  });
}
