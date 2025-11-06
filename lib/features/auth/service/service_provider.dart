import 'package:datn_mobile/features/auth/data/sources/auth_remote_source_provider.dart';
import 'package:datn_mobile/features/auth/domain/services/auth_service.dart';
import 'package:datn_mobile/features/auth/service/auth_service_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthServiceImpl(ref.watch(authRemoteSourceProvider));
});
