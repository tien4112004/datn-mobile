import 'dart:convert';

import 'package:datn_mobile/features/generate/data/dto/outline_generate_request_dto.dart';
import 'package:datn_mobile/features/generate/data/dto/presentation_generate_request_dto.dart';
import 'package:datn_mobile/features/generate/data/source/presentation_generate_remote_source.dart';
import 'package:datn_mobile/features/generate/domain/repository/presentation_generate_repository.dart';

class PresentationGenerateRepositoryImpl
    implements PresentationGenerateRepository {
  final PresentationGenerateRemoteSource _remoteSource;

  PresentationGenerateRepositoryImpl(this._remoteSource);

  @override
  Future<String> generateOutline(OutlineGenerateRequest outlineData) async {
    final response = await _remoteSource.generateOutline(outlineData);

    if (response.detail == null) {
      throw Exception('Failed to generate outline');
    }

    // The response detail is a JSON string (double encoded), so we need to decode it
    // to get the actual markdown text.
    String markdown = response.detail!;
    try {
      if (markdown.startsWith('"') && markdown.endsWith('"')) {
        markdown = jsonDecode(markdown) as String;
      }
    } catch (e) {
      // If decoding fails, assume it is already the raw markdown
    }

    return markdown;
  }

  @override
  Future<String> generatePresentation(
    PresentationGenerateRequest request,
  ) async {
    final response = await _remoteSource.generatePresentation(request);

    if (response.detail == null) {
      throw Exception('Failed to generate presentation');
    }

    return response.detail!;
  }
}
