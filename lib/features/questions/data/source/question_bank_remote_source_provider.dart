import 'package:AIPrimary/features/questions/data/source/question_bank_remote_source.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for QuestionBankRemoteSource.
final questionBankRemoteSourceProvider = Provider<QuestionBankRemoteSource>((
  ref,
) {
  final dio = ref.watch(dioPod);
  return QuestionBankRemoteSource(dio);
});
