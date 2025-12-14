import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:datn_mobile/shared/api_client/dio/dio_client_provider.dart';
import 'download_service.dart';
import 'download_service_impl.dart';

/// Riverpod provider for DownloadService
/// Injects the configured Dio instance
final downloadServiceProvider = Provider<DownloadService>((ref) {
  final dio = ref.read(dioPod);
  return DownloadServiceImpl(dio);
});
