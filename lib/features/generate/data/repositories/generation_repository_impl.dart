// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:datn_mobile/features/generate/data/dto/request/outline_generate_request.dart';
import 'package:datn_mobile/features/generate/domain/entities/generation_config.dart';
import 'package:datn_mobile/features/generate/domain/entities/generation_result.dart';
import 'package:datn_mobile/features/generate/domain/repositories/generation_repository.dart';
import 'package:datn_mobile/features/projects/enum/resource_type.dart';

/// Real implementation of GenerationRepository using API calls
class GenerationRepositoryImpl implements GenerationRepository {
  final Dio _dio; // Used for streaming in Phase 2b

  GenerationRepositoryImpl(this._dio);

  @override
  Future<GenerationResult> generate(GenerationConfig config) async {
    switch (config.resourceType) {
      case ResourceType.presentation:
        return _generatePresentationOutline(config);
      case ResourceType.image:
        return _generateImage(config);
      case ResourceType.mindmap:
        return _generateMindmap(config);
      case ResourceType.document:
        throw UnimplementedError('Document generation not supported yet');
    }
  }

  @override
  Stream<String> generateStream(GenerationConfig config) async* {
    switch (config.resourceType) {
      case ResourceType.presentation:
        yield* _generatePresentationOutlineStream(config);
      case ResourceType.image:
        throw UnimplementedError('Image streaming coming in future phase');
      case ResourceType.mindmap:
        throw UnimplementedError('Mindmap streaming coming in future phase');
      case ResourceType.document:
        throw UnimplementedError('Document generation not supported yet');
    }
  }

  /// Generate presentation outline using API
  /// Uses Retrofit client for non-streaming
  Future<GenerationResult> _generatePresentationOutline(
    GenerationConfig config,
  ) async {
    try {
      final request = config.toOutlineRequest();

      // Not using Retrofit here to keep it simple
      // final response = await _remoteSource.generateOutline(request);

      final response = await _dio.post(
        '/presentations/outline-generate',
        data: request.toJson(),
      );

      if (response.data == null) {
        throw Exception('Empty response from API');
      }

      // Status: 200
      // Message:
      // Data: "### Sharing Our Ideas Online: Digital Marketing Fun!\n\n---\n\n### Table of Contents\n-
      // What is Digital Marketing?\n- What Do We Share Online?\n- Where Do We Find It?\n- How Do We Share Our Message?
      //- Who Are We Talking To?\n- Why Do People Share Online?\n- Being Safe and Smart Online\n- Your Turn: Simple Sharing\n\n---\n\n
      //### What is Digital Marketing?\n- \"Digital\" means using computers or phones.\n
      //- \"Marketing\" is telling friends about something cool.\n- So, it's telling people online about cool stuff!\n
      //- It's a plan to share ideas on the internet.\n\n---\n\n### What Do We Share Online?\n...

      return GenerationResult(
        content: response.data!,
        generatedAt: DateTime.now(),
        resourceType: ResourceType.presentation,
      );
    } catch (e) {
      throw Exception('Failed to generate presentation: $e');
    }
  }

  /// Stream presentation outline generation
  /// Uses Dio directly with ResponseType.stream for streaming support
  Stream<String> _generatePresentationOutlineStream(
    GenerationConfig config,
  ) async* {
    final request = config.toOutlineRequest();

    try {
      final response = await _dio.post(
        '/presentations/outline-generate',
        data: request.toJson(),
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('API returned ${response.statusCode}');
      }

      // Stream the response chunks
      await for (final chunk in response.data.stream) {
        final text = utf8.decode(chunk);
        yield text;
      }
    } catch (e) {
      throw Exception('Failed to stream presentation: $e');
    }
  }

  /// Generate image (placeholder for Phase 2)
  Future<GenerationResult> _generateImage(GenerationConfig config) async {
    throw UnimplementedError('Image generation coming in future phase');
  }

  /// Generate mindmap (placeholder for Phase 2)
  Future<GenerationResult> _generateMindmap(GenerationConfig config) async {
    throw UnimplementedError('Mindmap generation coming in future phase');
  }
}
