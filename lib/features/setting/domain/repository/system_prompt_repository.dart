import 'package:AIPrimary/features/setting/data/dto/system_prompt_dto.dart';

abstract class SystemPromptRepository {
  Future<SystemPromptResponseDto?> getMyPrompt();
  Future<SystemPromptResponseDto> upsertMyPrompt(String prompt);
  Future<void> deleteMyPrompt();
}
