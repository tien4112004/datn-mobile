import 'dart:convert';

import 'package:datn_mobile/features/presentation_generate/data/dto/outline_generate_request_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/dto/presentation_generate_request_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/source/presentation_generate_remote_source.dart';
import 'package:datn_mobile/features/presentation_generate/data/source/presentation_generate_remote_source_provider.dart';
import 'package:datn_mobile/features/presentation_generate/domain/repository/presentation_generate_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'presentation_generate_repository_impl.dart';

// Uncomment the following line to use the real implementation
final presentationGenerateRepositoryProvider =
    Provider<PresentationGenerateRepository>((ref) {
      return PresentationGenerateRepositoryImpl(
        ref.read(presentationGenerateRemoteSourceProvider),
      );
    });
