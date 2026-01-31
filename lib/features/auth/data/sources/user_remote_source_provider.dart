import 'package:AIPrimary/features/auth/data/sources/user_remote_source.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRemoteSourceProvider = Provider<UserRemoteSource>((ref) {
  final dio = ref.watch(dioPod);
  return UserRemoteSource(dio);
});
