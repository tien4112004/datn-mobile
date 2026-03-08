import 'package:AIPrimary/features/setting/data/source/system_prompt_remote_source.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final systemPromptRemoteSourceProvider = Provider<SystemPromptRemoteSource>((
  ref,
) {
  final dio = ref.watch(dioPod);
  return SystemPromptRemoteSource(dio);
});
