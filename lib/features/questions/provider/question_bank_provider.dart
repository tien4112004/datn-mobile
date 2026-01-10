import 'package:datn_mobile/features/questions/data/repository/question_bank_repository_provider.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_bank_item_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'question_bank_state.dart';
part 'question_bank_notifier.dart';

/// Provider for Question Bank state management.
final questionBankProvider =
    NotifierProvider<QuestionBankNotifier, QuestionBankState>(() {
      return QuestionBankNotifier();
    });
