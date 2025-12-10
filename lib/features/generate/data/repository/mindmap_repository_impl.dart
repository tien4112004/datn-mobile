import 'package:datn_mobile/features/generate/data/dto/mindmap_generate_request_dto.dart';
import 'package:datn_mobile/features/generate/data/source/mindmap_remote_source.dart';
import 'package:datn_mobile/features/generate/domain/entity/mindmap_node_content.dart';
import 'package:datn_mobile/features/generate/domain/repository/mindmap_repository.dart';
import 'package:datn_mobile/features/generate/service/mindmap_parser.dart';

class MindmapRepositoryImpl implements MindmapRepository {
  final MindmapRemoteSource _remoteSource;

  MindmapRepositoryImpl(this._remoteSource);

  @override
  Future<MindmapNodeContent> generateMindmap(
    MindmapGenerateRequestDto request,
  ) async {
    final response = await _remoteSource.generateMindmap(request);

    if (response.detail == null || response.detail!.isEmpty) {
      throw Exception('Failed to generate mindmap: No data returned');
    }

    // The response.detail contains a JSON string of the mindmap structure
    return MindmapParser.parseJsonToMindmap(response.detail!);
  }
}
