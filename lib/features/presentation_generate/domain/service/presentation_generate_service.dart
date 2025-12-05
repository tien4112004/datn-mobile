import 'package:datn_mobile/features/presentation_generate/data/dto/outline_generate_request_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/dto/presentation_generate_request_dto.dart';

/// Abstract service interface for presentation generation.
abstract interface class PresentationGenerateService {
  /// Generates an outline based on the provided outline data.
  Future<String> generateOutline(OutlineGenerateRequest outlineData);

  /// Validates and generates a new presentation.
  Future<String> generatePresentation(PresentationGenerateRequest request);
}
