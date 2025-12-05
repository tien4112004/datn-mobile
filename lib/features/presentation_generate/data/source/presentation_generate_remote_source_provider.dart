import 'package:datn_mobile/features/presentation_generate/data/source/presentation_generate_remote_source.dart';
import 'package:datn_mobile/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final presentationGenerateRemoteSourceProvider =
    Provider<PresentationGenerateRemoteSource>((ref) {
      return PresentationGenerateRemoteSource(ref.read(dioPod));
    });
