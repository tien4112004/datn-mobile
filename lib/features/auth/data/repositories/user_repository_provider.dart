import 'package:AIPrimary/core/secure_storage/secure_storage_pod.dart';
import 'package:AIPrimary/features/auth/data/repositories/user_repository_impl.dart';
import 'package:AIPrimary/features/auth/data/sources/user_remote_source_provider.dart';
import 'package:AIPrimary/features/auth/domain/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteSource = ref.watch(userRemoteSourceProvider);
  final secureStorage = ref.watch(secureStoragePod);
  return UserRepositoryImpl(remoteSource, secureStorage);
});
