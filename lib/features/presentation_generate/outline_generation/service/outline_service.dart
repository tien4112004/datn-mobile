import 'package:dio/dio.dart';
import 'package:datn_mobile/features/presentation_generate/outline_generation/domain/entity/outline_entity.dart';
import 'package:datn_mobile/features/presentation_generate/outline_generation/data/source/outline_remote_source.dart';
import 'package:datn_mobile/features/presentation_generate/outline_generation/data/dto/outline_dto.dart';

class OutlineService {
  final OutlineRemoteSource _remoteSource;
  final Dio _dio;

  OutlineService(this._remoteSource, this._dio);

  /// Generate outline with streaming response
  /// Returns a Stream of text chunks from the backend
  ///
  /// Example usage:
  /// ```dart
  /// final stream = await service.generateOutlineStream(request);
  /// stream.listen(
  ///   (chunk) => print('Received: $chunk'),
  ///   onError: (error) => print('Error: $error'),
  ///   onDone: () => print('Stream completed'),
  /// );
  /// ```
  Future<Stream<String>> generateOutlineStream(OutlineRequest request) async {
    try {
      return await _remoteSource.generateOutlineStream(request.toDto(), _dio);
    } catch (e) {
      throw Exception('Failed to generate outline: $e');
    }
  }

  /// Generate outline with non-streaming response
  Future<OutlineResponse> generateOutline(OutlineRequest request) async {
    try {
      final dto = await _remoteSource.generateOutline(request.toDto());
      return dto.toEntity();
    } catch (e) {
      throw Exception('Failed to generate outline: $e');
    }
  }
}
