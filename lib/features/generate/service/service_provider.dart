import 'package:datn_mobile/features/generate/data/dto/image_generation_request_dto.dart';
import 'package:datn_mobile/features/generate/data/dto/mindmap_generate_request_dto.dart';
import 'package:datn_mobile/features/generate/data/dto/outline_generate_request_dto.dart';
import 'package:datn_mobile/features/generate/data/dto/presentation_generate_request_dto.dart';
import 'package:datn_mobile/features/generate/data/repository/repository_provider.dart';
import 'package:datn_mobile/features/generate/domain/entity/ai_model.dart';
import 'package:datn_mobile/features/generate/domain/entity/generated_image.dart';
import 'package:datn_mobile/features/generate/domain/entity/mindmap_node_content.dart';
import 'package:datn_mobile/features/generate/domain/repository/image_repository.dart';
import 'package:datn_mobile/features/generate/domain/repository/mindmap_repository.dart';
import 'package:datn_mobile/features/generate/domain/repository/presentation_generate_repository.dart';
import 'package:datn_mobile/features/generate/domain/service/image_service.dart';
import 'package:datn_mobile/features/generate/domain/service/mindmap_service.dart';
import 'package:datn_mobile/features/generate/domain/service/presentation_generate_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'image_service_impl.dart';
part 'mindmap_service_impl.dart';
part 'presentation_generate_service_impl.dart';

final presentationGenerateServiceProvider =
    Provider<PresentationGenerateService>((ref) {
      return PresentationGenerateServiceImpl(
        ref.read(presentationGenerateRepositoryProvider),
      );
    });

/// Provider for MindmapService
final mindmapServiceProvider = Provider<MindmapService>((ref) {
  return MindmapServiceImpl(ref.read(mindmapRepositoryProvider));
});

/// Provider for ImageService
final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageServiceImpl(ref.read(imageRepositoryProvider));
});
