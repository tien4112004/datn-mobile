import 'package:AIPrimary/shared/models/media_response.dart';
import 'package:dio/dio.dart';

class MediaService {
  final Dio dio;

  MediaService(this.dio);

  Future<MediaResponse> uploadMedia({required String filePath}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await dio.post('/media/upload', data: formData);
    return MediaResponse.fromJson(response.data);
  }

  Future<void> deleteMedia({required int id}) async {
    await dio.delete('media/$id');
  }

  Future<MediaResponse> getMedia({required int id}) async {
    final response = await dio.get('images/$id');
    return MediaResponse.fromJson(response.data);
  }
}
