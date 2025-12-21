import 'package:datn_mobile/features/generate/data/dto/art_style_dto.dart';
import 'package:datn_mobile/features/generate/data/source/art_style_remote_source_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that fetches art styles from the API
final artStylesProvider = FutureProvider<List<ArtStyleDto>>((ref) async {
  final remoteSource = ref.watch(artStyleRemoteSourceProvider);

  final response = await remoteSource.getArtStyles(
    page: 1,
    pageSize: 50, // Get all art styles at once
  );

  if (!response.success || response.data == null) {
    throw Exception(response.detail ?? 'Failed to fetch art styles');
  }

  // Filter only enabled art styles
  return response.data!.where((style) => style.isEnabled).toList();
});
