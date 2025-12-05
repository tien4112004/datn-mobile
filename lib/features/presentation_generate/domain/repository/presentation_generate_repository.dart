import 'package:datn_mobile/features/presentation_generate/data/dto/outline_generate_request_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/dto/outline_generate_response_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/dto/presentation_generate_request_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/dto/presentation_generate_response_dto.dart';

/// Abstract repository for presentation generation operations.
abstract class PresentationGenerateRepository {
  /// Generates an outline based on the provided outline data.
  Future<OutlineGenerateResponse> generateOutline(
    OutlineGenerateRequest outlineData,
  );

  /// Generates a new presentation based on the provided request.
  Future<PresentationGenerateResponse> generatePresentation(
    PresentationGenerateRequest request,
  );
}
