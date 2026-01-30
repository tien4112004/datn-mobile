import 'package:AIPrimary/core/secure_storage/secure_storage_pod.dart';
import 'package:AIPrimary/features/auth/data/sources/auth_remote_source_provider.dart';
import 'package:AIPrimary/features/auth/domain/services/auth_service.dart';
import 'package:AIPrimary/features/auth/service/auth_service_impl.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServicePod = Provider<AuthService>((ref) {
  return AuthServiceImpl(
    ref.watch(authRemoteSourcePod),
    ref.watch(secureStoragePod),
    ref.read(dioPod),
  );
});
