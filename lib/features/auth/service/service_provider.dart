import 'package:datn_mobile/core/secure_storage/secure_storage_pod.dart';
import 'package:datn_mobile/features/auth/data/sources/auth_remote_source_provider.dart';
import 'package:datn_mobile/features/auth/domain/services/auth_service.dart';
import 'package:datn_mobile/features/auth/service/auth_service_impl.dart';
import 'package:datn_mobile/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServicePod = Provider<AuthService>((ref) {
  return AuthServiceImpl(
    ref.watch(authRemoteSourcePod),
    ref.watch(secureStoragePod),
    ref.read(dioPod),
  );
});
