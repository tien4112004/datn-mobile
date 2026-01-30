import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'package:AIPrimary/shared/services/media_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mediaServiceProvider = Provider.autoDispose<MediaService>((ref) {
  final dio = ref.read(dioPod);
  return MediaService(dio);
});
