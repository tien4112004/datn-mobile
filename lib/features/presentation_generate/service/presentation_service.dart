import 'package:datn_mobile/features/presentation_generate/domain/entity/presentation_entity.dart';
import 'package:datn_mobile/features/presentation_generate/data/source/presentation_remote_source.dart';
import 'package:datn_mobile/features/presentation_generate/data/dto/presentation_dto.dart';

class PresentationService {
  final PresentationRemoteSource _remoteSource;

  PresentationService(this._remoteSource);

  Future<PresentationResponse> generatePresentation(PresentationRequest request) async {
    try {
      final dto = await _remoteSource.generatePresentation(request.toDto());
      return dto.toEntity();
    } catch (e) {
      throw Exception('Failed to generate presentation: $e');
    }
  }
}