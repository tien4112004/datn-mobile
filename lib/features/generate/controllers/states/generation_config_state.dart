import 'package:datn_mobile/features/generate/domain/entities/generation_config.dart';

class GenerationConfigState {
  final GenerationConfig config;

  GenerationConfigState({required this.config});

  GenerationConfigState copyWith({GenerationConfig? config}) {
    return GenerationConfigState(config: config ?? this.config);
  }

  @override
  String toString() => 'GenerationConfigState(config: $config)';
}
