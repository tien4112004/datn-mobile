import 'package:AIPrimary/features/auth/data/sources/auth_remote_source.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteSourcePod = Provider<AuthRemoteSource>((ref) {
  return AuthRemoteSource(ref.watch(dioPod));
});
