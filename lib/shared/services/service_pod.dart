import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dio/dio.dart';
import 'download_service.dart';
import 'share_service.dart';

final downloadDioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  return dio;
});

final downloadServiceProvider = Provider<DownloadService>((ref) {
  final dio = ref.read(downloadDioProvider);
  return DownloadService(dio);
});

final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService(ref.read(downloadServiceProvider));
});
