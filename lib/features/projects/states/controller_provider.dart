import 'package:datn_mobile/features/projects/domain/entity/presentation_minimal.dart';
import 'package:datn_mobile/features/projects/service/service_provider.dart';
import 'package:datn_mobile/features/projects/states/presentation_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:datn_mobile/features/projects/domain/entity/presentation.dart';

part 'presentation_controller.dart';

final presentationsControllerProvider =
    AsyncNotifierProvider<PresentationsController, PresentationListState>(
      () => PresentationsController(),
    );

final presentationByIdProvider = FutureProvider.family<Presentation, String>((
  ref,
  id,
) async {
  return ref.read(presentationServiceProvider).fetchPresentationById(id);
});

final createPresentationControllerProvider =
    AsyncNotifierProvider<CreatePresentationController, void>(
      () => CreatePresentationController(),
    );
