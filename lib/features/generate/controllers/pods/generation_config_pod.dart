// import 'package:datn_mobile/features/generate/controllers/pods/models_controller_pod.dart';
// import 'package:datn_mobile/features/generate/controllers/states/generation_config_state.dart';
// import 'package:datn_mobile/features/generate/domain/entities/generation_config.dart';
// import 'package:datn_mobile/features/projects/enum/resource_type.dart';
// import 'package:flutter_riverpod/legacy.dart';

// final generationConfigPod = StateProvider.family<GenerationConfigState, ResourceType>(
//   (ref, resourceType) => GenerationConfigState(
//     config: GenerationConfig.empty(
//       resourceType: resourceType,
//       model: ref
//           .read(modelsControllerPod(resourceType))
//           .firstWhere((model) => model.isDefault),
//     ),
//   ),
// )
