import 'package:datn_mobile/features/presentation_generate/presentation_generation/domain/entity/presentation_generation_entity.dart';
import 'package:datn_mobile/features/presentation_generate/presentation_generation/data/source/presentation_generation_remote_source.dart';
import 'package:datn_mobile/features/presentation_generate/presentation_generation/data/dto/presentation_generation_dto.dart';

class PresentationGenerationService {
  final PresentationGenerationRemoteSource _remoteSource;

  PresentationGenerationService(this._remoteSource);

  /// Generate presentation from outline
  /// Takes the outline from stage 1 and generates a complete presentation
  Future<PresentationGenerationResponse> generatePresentation(
    PresentationGenerationRequest request,
  ) async {
    try {
      final dto = await _remoteSource.generatePresentation(request.toDto());
      return dto.toEntity();
    } catch (e) {
      throw Exception('Failed to generate presentation: $e');
    }
  }
}
