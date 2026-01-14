import 'package:datn_mobile/features/questions/data/repository/question_bank_repository_impl.dart';
import 'package:datn_mobile/features/questions/data/source/question_bank_remote_source_provider.dart';
import 'package:datn_mobile/features/questions/domain/repository/question_bank_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for QuestionBankRepository.
final questionBankRepositoryProvider = Provider<QuestionBankRepository>((ref) {
  return QuestionBankRepositoryImpl(
    ref.watch(questionBankRemoteSourceProvider),
  );
});
