import 'package:AIPrimary/features/generate/data/source/example_prompt_remote_source.dart';
import 'package:AIPrimary/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for ExamplePromptRemoteSource
final examplePromptRemoteSourceProvider = Provider<ExamplePromptRemoteSource>((
  ref,
) {
  final dio = ref.watch(dioPod);
  return ExamplePromptRemoteSource(dio);
});
