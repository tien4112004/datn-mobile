import 'package:datn_mobile/features/projects/domain/entity/image_project.dart';
import 'package:datn_mobile/features/projects/service/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageByIdProvider = FutureProvider.family
    .autoDispose<ImageProject, String>((ref, imageId) async {
      return ref.read(imageServiceProvider).fetchImageById(imageId);
    });
