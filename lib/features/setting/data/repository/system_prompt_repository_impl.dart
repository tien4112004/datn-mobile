import 'package:AIPrimary/features/setting/data/dto/system_prompt_dto.dart';
import 'package:AIPrimary/features/setting/data/source/system_prompt_remote_source.dart';
import 'package:AIPrimary/features/setting/data/source/system_prompt_remote_source_provider.dart';
import 'package:AIPrimary/features/setting/domain/repository/system_prompt_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SystemPromptRepositoryImpl implements SystemPromptRepository {
  final SystemPromptRemoteSource _remoteSource;

  SystemPromptRepositoryImpl(this._remoteSource);

  @override
  Future<SystemPromptResponseDto?> getMyPrompt() async {
    final response = await _remoteSource.getMyPrompt();
    return response.data;
  }

  @override
  Future<SystemPromptResponseDto> upsertMyPrompt(String prompt) async {
    final response = await _remoteSource.upsertMyPrompt(
      SystemPromptRequestDto(prompt: prompt),
    );
    return response.data!;
  }

  @override
  Future<void> deleteMyPrompt() async {
    await _remoteSource.deleteMyPrompt();
  }
}

final systemPromptRepositoryProvider = Provider<SystemPromptRepository>((ref) {
  return SystemPromptRepositoryImpl(
    ref.watch(systemPromptRemoteSourceProvider),
  );
});
