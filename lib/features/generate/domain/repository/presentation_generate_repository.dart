import 'package:datn_mobile/features/generate/data/dto/outline_generate_request_dto.dart';
import 'package:datn_mobile/features/generate/data/dto/presentation_generate_request_dto.dart';

/// Abstract repository for presentation generation operations.
abstract class PresentationGenerateRepository {
  /// Generates an outline based on the provided outline data.
  Future<String> generateOutline(OutlineGenerateRequest outlineData);

  /// Generates a new presentation based on the provided request.
  Future<String> generatePresentation(PresentationGenerateRequest request);
}
