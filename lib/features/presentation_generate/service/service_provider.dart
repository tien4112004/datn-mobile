import 'package:datn_mobile/features/presentation_generate/data/dto/outline_generate_request_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/dto/outline_generate_response_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/dto/presentation_generate_request_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/dto/presentation_generate_response_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/repository/repository_provider.dart';
import 'package:datn_mobile/features/presentation_generate/domain/repository/presentation_generate_repository.dart';
import 'package:datn_mobile/features/presentation_generate/domain/service/presentation_generate_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'presentation_generate_service_impl.dart';

final presentationGenerateServiceProvider =
    Provider<PresentationGenerateService>((ref) {
      return PresentationGenerateServiceImpl(
        ref.read(presentationGenerateRepositoryProvider),
      );
    });
