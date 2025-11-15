import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:datn_mobile/features/presentation_generate/outline_generation/data/dto/outline_dto.dart';

part 'outline_remote_source.g.dart';

@RestApi()
abstract class OutlineRemoteSource {
  factory OutlineRemoteSource(Dio dio) = _OutlineRemoteSource;

  @POST('/api/presentations/outline-generate')
  Future<OutlineResponseDto> generateOutline(@Body() OutlineRequestDto request);
}

/// Extension to add streaming method not handled by Retrofit
extension OutlineRemoteSourceStream on OutlineRemoteSource {
  /// Generate outline with streaming response
  /// Returns a Stream of text chunks from the backend
  Future<Stream<String>> generateOutlineStream(
    OutlineRequestDto request,
    Dio dio,
  ) async {
    try {
      final response = await dio.post(
        '/api/presentations/outline-generate',
        data: request.toJson(),
        options: Options(responseType: ResponseType.stream),
      );

      // Convert the streaming response to String stream
      return (response.data as ResponseBody).stream
          .map((bytes) => String.fromCharCodes(bytes))
          .where((text) => text.isNotEmpty);
    } catch (e) {
      throw Exception('Failed to stream outline: $e');
    }
  }
}
