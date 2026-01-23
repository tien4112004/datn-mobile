import 'dart:async';

import 'package:datn_mobile/features/questions/data/repository/question_bank_repository_provider.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_bank_item_entity.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_create_request_entity.dart';
import 'package:datn_mobile/shared/models/cms_enums.dart';
import 'package:datn_mobile/features/questions/domain/entity/question_update_request_entity.dart';
import 'package:datn_mobile/features/questions/states/question_bank_filter_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

part 'question_bank_state.dart';
part 'question_bank_controller.dart';

/// Provider for Question Bank state management.
final questionBankProvider =
    AsyncNotifierProvider<QuestionBankController, QuestionBankState>(() {
      return QuestionBankController();
    });

final questionBankFilterProvider = StateProvider<QuestionBankFilterState>((
  ref,
) {
  return const QuestionBankFilterState();
});
