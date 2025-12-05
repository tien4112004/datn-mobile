import 'package:datn_mobile/features/presentation_generate/data/dto/slide_theme_dto.dart';
import 'package:datn_mobile/features/presentation_generate/data/source/slide_theme_remote_source_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that fetches slide themes from the API
final slideThemesProvider = FutureProvider<List<SlideThemeDto>>((ref) async {
  final remoteSource = ref.watch(slideThemeRemoteSourceProvider);

  final response = await remoteSource.getSlideThemes(
    page: 1,
    pageSize: 50, // Get all themes at once
  );

  if (!response.success || response.data == null) {
    throw Exception(response.detail ?? 'Failed to fetch slide themes');
  }

  return response.data!;
});
