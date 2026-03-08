import 'package:AIPrimary/features/setting/data/dto/system_prompt_dto.dart';
import 'package:AIPrimary/features/setting/data/repository/system_prompt_repository_impl.dart';
import 'package:AIPrimary/features/setting/domain/repository/system_prompt_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SystemPromptController extends AsyncNotifier<SystemPromptResponseDto?> {
  SystemPromptRepository get _repository =>
      ref.read(systemPromptRepositoryProvider);

  @override
  Future<SystemPromptResponseDto?> build() async {
    return _repository.getMyPrompt();
  }

  Future<void> upsertPrompt(String prompt) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.upsertMyPrompt(prompt));
  }

  Future<void> deletePrompt() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteMyPrompt();
      return null;
    });
  }
}

final systemPromptControllerProvider =
    AsyncNotifierProvider<SystemPromptController, SystemPromptResponseDto?>(
      SystemPromptController.new,
    );
