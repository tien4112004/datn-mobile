import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datn_mobile/features/presentation_generate/outline_generation/domain/entity/outline_entity.dart';
import 'package:datn_mobile/features/presentation_generate/outline_generation/service/outline_service_provider.dart';

part 'outline_controller.dart';

final outlineFormControllerProvider =
    NotifierProvider<OutlineFormController, OutlineRequest>(
      () => OutlineFormController(),
    );

final generateOutlineControllerProvider =
    AsyncNotifierProvider<GenerateOutlineController, Stream<String>?>(
      () => GenerateOutlineController(),
    );
