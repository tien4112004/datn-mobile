import 'package:datn_mobile/features/generate/data/source/slide_theme_remote_source.dart';
import 'package:datn_mobile/shared/api_client/dio/dio_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for SlideThemeRemoteSource
final slideThemeRemoteSourceProvider = Provider<SlideThemeRemoteSource>((ref) {
  final dio = ref.watch(dioPod);
  return SlideThemeRemoteSource(dio);
});
