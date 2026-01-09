import 'package:datn_mobile/features/auth/data/repositories/user_repository_impl.dart';
import 'package:datn_mobile/features/auth/data/sources/user_remote_source_provider.dart';
import 'package:datn_mobile/features/auth/domain/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteSource = ref.watch(userRemoteSourceProvider);
  return UserRepositoryImpl(remoteSource);
});
