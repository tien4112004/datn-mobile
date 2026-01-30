import 'package:AIPrimary/features/questions/states/question_form/question_form_notifier.dart';
import 'package:AIPrimary/features/questions/states/question_form/question_form_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Provider for question form state
final questionFormProvider =
    StateNotifierProvider.autoDispose<QuestionFormNotifier, QuestionFormState>(
      (ref) => QuestionFormNotifier(),
    );

/// Selector for hasUnsavedChanges to prevent unnecessary rebuilds
final hasUnsavedChangesProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(
    questionFormProvider.select((state) => state.hasUnsavedChanges),
  );
});

/// Selector for isLoading
final isFormLoadingProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(questionFormProvider.select((state) => state.isLoading));
});

/// Selector for form validation error
final formValidationErrorProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(questionFormProvider.select((state) => state.validate()));
});
