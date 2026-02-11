import 'package:AIPrimary/features/submissions/data/repository/submission_repository_impl.dart';
import 'package:AIPrimary/features/submissions/data/source/submission_remote_source.dart';
import 'package:AIPrimary/features/submissions/domain/repository/submission_repository.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for SubmissionRemoteSource
final submissionRemoteSourceProvider = Provider<SubmissionRemoteSource>((ref) {
  final dio = ref.watch(dioPod);
  return SubmissionRemoteSource(dio);
});

/// Provider for SubmissionRepository
final submissionRepositoryProvider = Provider<SubmissionRepository>((ref) {
  final remoteSource = ref.watch(submissionRemoteSourceProvider);
  return SubmissionRepositoryImpl(remoteSource);
});
