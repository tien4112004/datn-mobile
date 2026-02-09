import 'package:AIPrimary/features/generate/data/dto/example_prompt_dto.dart';
import 'package:AIPrimary/features/generate/data/source/example_prompt_remote_source_provider.dart';
import 'package:AIPrimary/shared/pods/translation_pod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that fetches example prompts from the API by type.
///
/// Parameterized by prompt type (e.g. "MINDMAP", "PRESENTATION", "IMAGE").
/// Automatically uses the current app locale for the language parameter.
final examplePromptsProvider =
    FutureProvider.family<List<ExamplePromptDto>, String>((ref, type) async {
      final remoteSource = ref.watch(examplePromptRemoteSourceProvider);
      final t = ref.watch(translationsPod);
      final language = t.$meta.locale.languageCode;

      final response = await remoteSource.getExamplePrompts(
        type: type,
        language: language,
      );

      if (!response.success || response.data == null) {
        return [];
      }

      return response.data!;
    });
